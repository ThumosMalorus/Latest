#!/bin/zsh
# Builds this fork, signs it with the local "Latest Fork Local Signing" certificate
# and installs it as "/Applications/Latest (Fork).app".
#
# The stable local signature lets macOS keep the App Management permission across
# rebuilds, which Homebrew updates need to replace apps in /Applications.
set -euo pipefail

cd "$(dirname "$0")/.."

IDENTITY="Latest Fork Local Signing"
KEYCHAIN="$HOME/Library/Keychains/latest-fork-signing.keychain-db"
APP="build/Build/Products/Release/Latest.app"
DEST="/Applications/Latest (Fork).app"

rm -rf build/Build/Products/Release
xcodebuild -project Latest.xcodeproj -scheme Latest -configuration Release \
	-derivedDataPath build CODE_SIGNING_ALLOWED=NO build | grep -E "error:|BUILD (SUCCEEDED|FAILED)"

security unlock-keychain -p "$(security find-generic-password -s latest-fork-signing -w)" "$KEYCHAIN"
codesign --force --deep --sign "$IDENTITY" --keychain "$KEYCHAIN" "$APP"
codesign --verify --deep --strict "$APP"

osascript -e 'quit app id "com.thumosmalorus.Latest"' 2>/dev/null || true
sleep 1
rm -rf "$DEST"
ditto "$APP" "$DEST"
open "$DEST"
echo "Installed $DEST"
