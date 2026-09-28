#!/bin/zsh
set -euo pipefail
root=${0:A:h:h}
cd "$root"
[[ -f dist/Claude-Weekly-Usage-Mac-Installer.zip ]] || { print -u2 -- "Run ./scripts/package.sh first."; exit 1; }
workspace=$(mktemp -d "$root/.build/verify.XXXXXX")
trap 'rm -rf "$workspace"' EXIT
ditto -x -k dist/Claude-Weekly-Usage-Mac-Installer.zip "$workspace/extracted"
package="$workspace/extracted/Claude Weekly Usage"
test -x "$package/install.command"
test -x "$package/uninstall.command"
codesign --verify --strict --all-architectures "$package/Claude Weekly Usage.app"
test_root="$workspace/다른 사용자 & spaces"
"$package/install.command" --prepare-only "$test_root"
plist="$test_root/Library/LaunchAgents/io.github.2jungi.claude-weekly-usage-bar.plist"
actual=$(plutil -extract ProgramArguments.0 raw -o - "$plist")
[[ "$actual" == "$test_root/Applications/Claude Weekly Usage.app/Contents/MacOS/ClaudeWeeklyUsage" ]]
"$package/install.command" --prepare-only "$test_root"
backups=("$test_root/Applications"/*이전*.app(N))
(( ${#backups} == 1 ))
"$package/uninstall.command" --prepare-only "$test_root"
test ! -e "$plist"
test ! -e "$test_root/Applications/Claude Weekly Usage.app"
trashed=("$test_root/.Trash"/*/Claude\ Weekly\ Usage.app(N))
(( ${#trashed} == 1 ))
conflict_root="$workspace/conflict"
mkdir -p "$conflict_root/Applications/Claude Weekly Usage.app"
print -- "keep me" > "$conflict_root/Applications/Claude Weekly Usage.app/unrelated.txt"
if "$package/install.command" --prepare-only "$conflict_root" >"$workspace/expected-error.txt" 2>&1; then
  print -u2 -- "FAIL: installer accepted an unrelated existing directory"
  exit 1
fi
[[ "$(cat "$conflict_root/Applications/Claude Weekly Usage.app/unrelated.txt")" == "keep me" ]]
print -- "PASS: archive permissions/signatures, portable paths, upgrade backup, uninstall, collision protection"
