#!/usr/bin/env python3
"""Every promise in tests/posture.tftest.hcl, broken on a copy, has to be noticed.

A test that cannot fail is not a test. Each line of tests/plants.tsv names a
file, a piece of it, and what to put there instead, and each one breaks one
property the posture test asserts: key rotation off, a bucket allowed to go
public, a database default flipped to internet-facing. This runs the test on
an untouched copy first, which has to pass, then on one copy per plant, each
of which has to fail. A plant whose text is no longer in the file fails the
run too, so the test cannot fall behind the configuration unnoticed.

    TERRAFORM_IMAGE=<pinned image> ./tests/plant_violations.py
"""
import json
import os
import shutil
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
IMAGE = os.environ["TERRAFORM_IMAGE"]
PLATFORM = os.environ.get("TERRAFORM_PLATFORM")


def terraform_test(d):
    cmd = ["docker", "run", "--rm"] + (["--platform", PLATFORM] if PLATFORM else [])
    cmd += ["-v", "%s:/mnt" % d, "-w", "/mnt", IMAGE, "test", "-no-color"]
    return subprocess.run(cmd, capture_output=True, text=True)


def copy():
    work = tempfile.mkdtemp(prefix="plant-")
    shutil.copytree(ROOT, work, dirs_exist_ok=True, symlinks=True, ignore=shutil.ignore_patterns(".git"))
    return work


def main():
    plants = []
    with open(os.path.join(ROOT, "tests", "plants.tsv"), encoding="utf-8") as f:
        for line in f:
            if line.startswith("#") or not line.strip():
                continue
            plants.append([json.loads(x) for x in line.rstrip("\n").split("\t")])
    if not plants:
        sys.exit("tests/plants.tsv has no plants: a posture test nothing tries to break proves nothing")

    work = copy()
    r = terraform_test(work)
    shutil.rmtree(work, ignore_errors=True)
    if r.returncode != 0:
        print(r.stdout[-2000:] + r.stderr[-2000:])
        sys.exit("the untouched configuration does not pass its own posture test")
    print("  ok      the untouched configuration passes")

    missed = stale = 0
    for fname, old, new, what in plants:
        work = copy()
        path = os.path.join(work, fname)
        text = open(path, encoding="utf-8").read()
        if old not in text:
            print("  STALE   %s: the text this plant breaks is no longer in %s" % (what, fname))
            stale += 1
            shutil.rmtree(work, ignore_errors=True)
            continue
        open(path, "w", encoding="utf-8").write(text.replace(old, new, 1))
        r = terraform_test(work)
        shutil.rmtree(work, ignore_errors=True)
        if r.returncode == 0:
            print("  MISSED  %s" % what)
            missed += 1
        else:
            print("  caught  %s" % what)
    print("%d plants: %d caught, %d missed, %d stale" % (len(plants), len(plants) - missed - stale, missed, stale))
    sys.exit(1 if (missed or stale) else 0)


if __name__ == "__main__":
    main()
