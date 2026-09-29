#!/bin/zsh
set -euo pipefail
root=${0:A:h:h}
cd "$root"
./scripts/build.sh
mkdir -p dist
stage=$(mktemp -d "$root/.build/package.XXXXXX")
trap 'rm -rf "$stage"' EXIT
package="$stage/Weekly Usage"
mkdir -p "$package"
ditto '.build/Weekly Usage.app' "$package/Weekly Usage.app"
cp packaging/install.command packaging/uninstall.command "$package/"
cp ../docs/codex.md "$package/README.md"
cp ../docs/codex.en.md "$package/README.en.md"
cp ../CONTRIBUTING.md ../CHANGELOG.md ../LICENSE ../THIRD_PARTY_NOTICES.md "$package/"
chmod 755 "$package/install.command" "$package/uninstall.command"
archive="$root/dist/Weekly-Usage-Mac-Installer.zip"
ditto -c -k --norsrc --noextattr --keepParent "$package" "$archive"
(cd dist && shasum -a 256 Weekly-Usage-Mac-Installer.zip > SHA256SUMS.txt)
print -- "Packaged: $archive"
