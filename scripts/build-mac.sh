#!/usr/bin/env bash
# Builds BambooKit for macOS (Apple Silicon + Intel DMGs and zips) from the bambookit-application
# monorepo — the same source as the Windows app — into ./release.
#
#   scripts/build-mac.sh [path/to/bambookit-application]
#
# Requirements: macOS, bun >= 1.3.14, Xcode Command Line Tools.
# Sign-in config is read from packages/desktop/.env.bambookit in the application repo
# (see .env.bambookit.example there). Without it the app builds but shows "BambooKit not configured".
#
# Builds are ad-hoc signed and not notarized (no Apple Developer ID). To sign and notarize, set
# CSC_LINK/CSC_KEY_PASSWORD and APPLE_ID/APPLE_APP_SPECIFIC_PASSWORD/APPLE_TEAM_ID and pass --notarize.

set -euo pipefail

HERE="$(cd "$(dirname "$0")/.." && pwd)"
APP_REPO="${1:-$HERE/../bambookit-application}"
APP_REPO="$(cd "$APP_REPO" && pwd)"
DESKTOP="$APP_REPO/packages/desktop"
OUT="$HERE/release"
NOTARIZE=false
for arg in "$@"; do [ "$arg" = "--notarize" ] && NOTARIZE=true; done

[ -f "$DESKTOP/electron-builder.config.ts" ] || { echo "Not a bambookit-application checkout: $APP_REPO" >&2; exit 1; }

BUN_VERSION="$(bun --version)"
REQUIRED="$(sed -n 's/.*"packageManager": *"bun@\([^"]*\)".*/\1/p' "$APP_REPO/package.json")"
if [ "$(printf '%s\n%s\n' "$REQUIRED" "$BUN_VERSION" | sort -V | head -n1)" != "$REQUIRED" ]; then
  echo "bun $REQUIRED or newer is required (found $BUN_VERSION). Run: bun upgrade" >&2
  exit 1
fi

if [ ! -f "$DESKTOP/.env.bambookit" ]; then
  echo "warning: $DESKTOP/.env.bambookit is missing — sign-in will be disabled in this build." >&2
fi

VERSION="$(sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' "$DESKTOP/package.json" | head -n1)"
echo "==> Building BambooKit $VERSION for macOS from $APP_REPO"

cd "$APP_REPO"
# Native modules (terminal, file watcher) for both Mac architectures.
bun install --os=darwin --cpu=x64 --cpu=arm64

cd "$DESKTOP"
export OPENCODE_CHANNEL=prod
bun run prebuild
bun run build

SIGN_ARGS=(-c.mac.identity=- -c.mac.notarize=false -c.mac.hardenedRuntime=false -c.dmg.sign=false)
$NOTARIZE && SIGN_ARGS=()

rm -rf dist
for ARCH in arm64 x64; do
  echo "==> Packaging $ARCH"
  npx electron-builder --mac "--$ARCH" --config electron-builder.config.ts --publish never \
    "-c.artifactName=BambooKit-\${version}-mac-\${arch}.\${ext}" "${SIGN_ARGS[@]}"
done

mkdir -p "$OUT"
rm -f "$OUT"/BambooKit-*-mac-*
cp dist/BambooKit-"$VERSION"-mac-*.dmg dist/BambooKit-"$VERSION"-mac-*.zip "$OUT"/
(cd "$OUT" && shasum -a 256 BambooKit-"$VERSION"-mac-* > SHA256SUMS.txt)

echo "==> Done:"
ls -lh "$OUT"
