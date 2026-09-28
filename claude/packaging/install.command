#!/bin/zsh
set -euo pipefail

package_dir=${0:A:h}
source_app="$package_dir/Claude Weekly Usage.app"
install_root="$HOME"
prepare_only=false
if (( $# > 0 )); then
  if [[ $# -eq 2 && "$1" == "--prepare-only" && "$2" == /* ]]; then
    install_root="$2"
    prepare_only=true
  else
    print -u2 -- "지원하지 않는 설치 옵션입니다."
    exit 1
  fi
fi

label="io.github.2jungi.claude-weekly-usage-bar"
user_id=$(/usr/bin/id -u)
apps_dir="$install_root/Applications"
target_app="$apps_dir/Claude Weekly Usage.app"
agents_dir="$install_root/Library/LaunchAgents"
agent_file="$agents_dir/$label.plist"

function fail() {
  print -u2 -- "설치를 완료하지 못했습니다: $1"
  exit 1
}

[[ -f "$source_app/Contents/Info.plist" && -x "$source_app/Contents/MacOS/ClaudeWeeklyUsage" ]] || fail "압축을 완전히 푼 폴더에서 install.command를 실행하세요."
/usr/bin/codesign --verify --strict "$source_app" || fail "앱 파일 검증에 실패했습니다. ZIP을 다시 받아주세요."
os_version=$(/usr/bin/sw_vers -productVersion)
[[ ${os_version%%.*} -ge 13 ]] || fail "macOS 13 Ventura 이상이 필요합니다."
if [[ -e "$target_app" ]]; then
  existing_id=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$target_app/Contents/Info.plist" 2>/dev/null) || fail "같은 이름의 다른 파일이 이미 있습니다."
  [[ "$existing_id" == "$label" ]] || fail "같은 이름의 다른 앱이 이미 있습니다."
fi

print -- "Claude Weekly Usage를 설치합니다."
/bin/mkdir -p "$apps_dir" "$agents_dir"
staging=$(/usr/bin/mktemp -d "$apps_dir/.weekly-usage.XXXXXX")
trap '/bin/rm -rf "$staging"' EXIT
/usr/bin/ditto "$source_app" "$staging/Claude Weekly Usage.app"
/usr/bin/codesign --verify --strict "$staging/Claude Weekly Usage.app"

new_agent="$staging/$label.plist"
/usr/bin/plutil -create xml1 "$new_agent"
/usr/bin/plutil -insert Label -string "$label" "$new_agent"
/usr/bin/plutil -insert ProgramArguments -xml '<array/>' "$new_agent"
/usr/bin/plutil -insert ProgramArguments.0 -string "$target_app/Contents/MacOS/ClaudeWeeklyUsage" "$new_agent"
/usr/bin/plutil -insert RunAtLoad -bool YES "$new_agent"
/usr/bin/plutil -insert LimitLoadToSessionType -string Aqua "$new_agent"
/usr/bin/plutil -insert ProcessType -string Interactive "$new_agent"
/usr/bin/plutil -lint "$new_agent" >/dev/null

if [[ "$prepare_only" == false ]]; then
  "$source_app/Contents/MacOS/ClaudeWeeklyUsage" --quit-running
  /bin/launchctl bootout "gui/$user_id/$label" >/dev/null 2>&1 || true
fi
if [[ -e "$target_app" ]]; then
  backup="$apps_dir/Claude Weekly Usage 이전 버전 $(/bin/date +%Y%m%d-%H%M%S)-$$.app"
  /bin/mv "$target_app" "$backup"
  print -- "이전 버전 보관: $backup"
fi
/bin/mv "$staging/Claude Weekly Usage.app" "$target_app"
/bin/mv "$new_agent" "$agent_file"
/bin/chmod 644 "$agent_file"

if [[ "$prepare_only" == true ]]; then
  print -- "설치 파일 준비 검증 완료: $install_root"
  exit 0
fi

/bin/launchctl enable "gui/$user_id/$label"
/usr/bin/open "$target_app" || fail "앱 열기가 차단되면 동봉된 사용 안내의 첫 실행 방법을 확인하세요."
print -- ""
print -- "설치 완료! 메뉴바에 잔액 %와 Claude 로고가 표시됩니다."
print -- "앱 위치: $target_app"
print -- "다음 로그인부터 자동 실행됩니다."
print -- "--%가 표시되면 맥북의 Claude/Claude Code 로그인 상태를 확인하세요."
print -- "이 터미널 창은 닫아도 됩니다."
