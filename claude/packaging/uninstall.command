#!/bin/zsh
set -euo pipefail
install_root="$HOME"
prepare_only=false
if (( $# > 0 )); then
  if [[ $# -eq 2 && "$1" == "--prepare-only" && "$2" == /* ]]; then
    install_root="$2"
    prepare_only=true
  else
    print -u2 -- "Unsupported arguments."
    exit 1
  fi
fi
label="io.github.2jungi.claude-weekly-usage-bar"
app="$install_root/Applications/Claude Weekly Usage.app"
agent="$install_root/Library/LaunchAgents/$label.plist"
if [[ -e "$app" ]]; then
  actual=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$app/Contents/Info.plist")
  [[ "$actual" == "$label" ]] || { print -u2 -- "Different app found; nothing removed."; exit 1; }
fi
if [[ -e "$agent" ]]; then
  actual=$(/usr/libexec/PlistBuddy -c 'Print :Label' "$agent")
  [[ "$actual" == "$label" ]] || { print -u2 -- "Different login item found; nothing removed."; exit 1; }
fi
if [[ "$prepare_only" == false ]]; then
  user_id=$(/usr/bin/id -u)
  /bin/launchctl bootout "gui/$user_id/$label" >/dev/null 2>&1 || true
  if [[ -x "$app/Contents/MacOS/ClaudeWeeklyUsage" ]]; then
    "$app/Contents/MacOS/ClaudeWeeklyUsage" --quit-running
  fi
fi
trash="$install_root/.Trash/Claude Weekly Usage $(/bin/date +%Y%m%d-%H%M%S)-$$"
/bin/mkdir -p "$trash"
[[ ! -e "$agent" ]] || /bin/mv "$agent" "$trash/"
[[ ! -e "$app" ]] || /bin/mv "$app" "$trash/"
print -- "제거 완료 / Uninstalled. App and login item moved to Trash."
print -- "Claude Code와 로그인 정보는 그대로 유지됩니다 / Your Claude Code installation and login are unchanged."
