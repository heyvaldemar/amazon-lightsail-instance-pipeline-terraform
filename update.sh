#!/bin/bash
# Update this configuration to the latest release of the template.
#
# Moves between RELEASE TAGS, never to an arbitrary commit: a tag is a
# combination this repository's CI has formatted, initialised against its
# lockfile, validated and linted. Refuses to cross a major version
# unattended, refuses to run over local changes, and names any variable that
# became required since the version you are on.
#
# IT NEVER APPLIES. The last thing it does is print a plan. Applying a plan
# against live infrastructure is a decision, and a script that made it for
# you would be a script nobody should run.
#
#   ./update.sh              update to the latest release, then plan
#   ./update.sh --dry-run    say what would happen
#   ./update.sh --no-plan    update the files only
#   ./update.sh --allow-major   cross a major version, after reading its notes
set -euo pipefail
cd "$(dirname "$0")"

DRY_RUN=false
ALLOW_MAJOR=false
PLAN=true
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --no-plan) PLAN=false ;;
    --allow-major) ALLOW_MAJOR=true ;;
    *) echo "unknown flag: $arg" >&2; exit 2 ;;
  esac
done

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "local changes present — commit or stash them first, nothing updated" >&2
  exit 1
fi

git fetch --tags --quiet origin

latest="$(git tag -l 'v*' --sort=-v:refname | head -1)"
if [ -z "$latest" ]; then
  echo "no release tags found — nothing to update to" >&2
  exit 1
fi

current="$(git describe --tags --abbrev=0 2>/dev/null || echo 'v0.0.0')"
if [ "$(git rev-parse HEAD)" = "$(git rev-parse "$latest^{commit}")" ]; then
  echo "already on $latest"
  exit 0
fi

cur_major="${current#v}"; cur_major="${cur_major%%.*}"
new_major="${latest#v}";  new_major="${new_major%%.*}"
if [ "$new_major" != "$cur_major" ] && [ "$ALLOW_MAJOR" != "true" ]; then
  echo "refusing to cross a major version unattended: $current -> $latest" >&2
  echo "read the release notes, then re-run with --allow-major:" >&2
  echo "  https://github.com/heyvaldemar/amazon-lightsail-instance-pipeline-terraform/releases/tag/$latest" >&2
  exit 3
fi

# NEW VARIABLES SINCE YOUR VERSION. A release can add a variable with no
# default, and `terraform plan` would then stop asking for it interactively -
# after the checkout, with the tree already on the new tag. Better to say so
# here, before anything has moved. Names only, never values.
_new="$(comm -13 <(git show "HEAD:00-variables.tf" 2>/dev/null | grep -oE '^variable "[A-Za-z0-9_]+"' | sed -E 's/^variable "//; s/"$//' | sort -u) \
                 <(git show "$latest:00-variables.tf" 2>/dev/null | grep -oE '^variable "[A-Za-z0-9_]+"' | sed -E 's/^variable "//; s/"$//' | sort -u))"
if [ -n "$_new" ]; then
  echo "new variables in 00-variables.tf since $current:"
  while IFS= read -r _k; do echo "  $_k"; done <<<"$_new"
  # A variable with no default has to be given a value before plan will run.
  _missing=""
  for _k in $_new; do
    if ! git show "$latest:00-variables.tf" | awk -v n="$_k" '
          $0 ~ "^variable \"" n "\"" { inside = 1 }
          inside && /default/ { found = 1 }
          inside && /^}/ { exit }
          END { exit !found }'; then
      grep -qE "^[[:space:]]*${_k}[[:space:]]*=" ./*.tfvars ./*.auto.tfvars 2>/dev/null || _missing="$_missing $_k"
    fi
  done
  if [ -n "$_missing" ]; then
    echo "required in $latest with no default and no value in a .tfvars here:$_missing" >&2
    echo "see 00-variables.tf at $latest for what each one is; nothing was changed" >&2
    [ "$DRY_RUN" = "true" ] || exit 4
  fi
fi

echo "updating $current -> $latest"
if [ "$DRY_RUN" = "true" ]; then
  git log --oneline "HEAD..$latest^{commit}" | sed 's/^/  would apply: /'
  echo "dry run — nothing changed"
  exit 0
fi

git checkout -q "$latest"
echo "now on $latest"

if [ "$PLAN" != "true" ]; then
  echo "files updated; run 'terraform init' and 'terraform plan' yourself"
  exit 0
fi

# init -upgrade, because the lockfile that came with the release may name
# providers this working directory has never downloaded.
terraform init -upgrade -input=false
echo
echo "== the plan below is what would change in your account. Nothing has been applied."
echo "== read it, then run 'terraform apply' yourself if it is what you meant."
echo
terraform plan
