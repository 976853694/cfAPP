#!/usr/bin/env bash
# Package a built .app into an unsigned .ipa (Payload + zip).
# Usage: package-unsigned-ipa.sh <path-to.app> <output.ipa>
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "usage: $0 <App.app> <out.ipa>" >&2
  exit 2
fi

APP_PATH="$1"
IPA_PATH="$2"

if [[ ! -d "$APP_PATH" ]]; then
  echo "error: app not found: $APP_PATH" >&2
  exit 1
fi

APP_NAME="$(basename "$APP_PATH")"
if [[ "$APP_NAME" != *.app ]]; then
  echo "error: expected a .app bundle, got: $APP_NAME" >&2
  exit 1
fi

OUT_DIR="$(dirname "$IPA_PATH")"
mkdir -p "$OUT_DIR"

WORK="$(mktemp -d "${TMPDIR:-/tmp}/unsigned-ipa.XXXXXX")"
cleanup() { rm -rf "$WORK"; }
trap cleanup EXIT

mkdir -p "$WORK/Payload"
# Preserve symlinks and permissions inside the .app
ditto "$APP_PATH" "$WORK/Payload/$APP_NAME"

# IPA is a zip with Payload/ at the root (no compression of already-compressed assets is fine)
(
  cd "$WORK"
  # -y store symlinks as links; -r recursive; -q quiet
  zip -qry "$IPA_PATH" Payload
)

if [[ ! -f "$IPA_PATH" ]]; then
  echo "error: failed to write $IPA_PATH" >&2
  exit 1
fi

echo "Wrote unsigned IPA: $IPA_PATH ($(du -h "$IPA_PATH" | awk '{print $1}'))"
