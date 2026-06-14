#!/usr/bin/env bash
#
# Bump the SemVer version field of a chart's Chart.yaml.
#
# Usage:
#   scripts/bump-version.sh --name NAME [--major|--minor|--patch]
#
set -euo pipefail

NAME=""
PART="patch"

usage() {
  grep '^#' "$0" | sed 's/^#//'
  exit 1
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --name) NAME="$2"; shift 2 ;;
    --major) PART="major"; shift ;;
    --minor) PART="minor"; shift ;;
    --patch) PART="patch"; shift ;;
    -h|--help) usage ;;
    *) echo "Unknown argument: $1" >&2; usage ;;
  esac
done

if [ -z "$NAME" ]; then
  echo "Error: --name is required." >&2
  usage
fi

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHART_FILE="${REPO_ROOT}/charts/${NAME}/Chart.yaml"

if [ ! -f "$CHART_FILE" ]; then
  echo "Error: ${CHART_FILE} not found." >&2
  exit 1
fi

current="$(awk '/^version:/ {print $2; exit}' "$CHART_FILE")"
if ! printf '%s' "$current" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  echo "Error: current version '${current}' is not a plain SemVer." >&2
  exit 1
fi

IFS='.' read -r major minor patch <<EOF
${current}
EOF

case "$PART" in
  major) major=$((major + 1)); minor=0; patch=0 ;;
  minor) minor=$((minor + 1)); patch=0 ;;
  patch) patch=$((patch + 1)) ;;
esac

next="${major}.${minor}.${patch}"
sed -i "s/^version: .*/version: ${next}/" "$CHART_FILE"

echo "Bumped ${NAME}: ${current} -> ${next}"
