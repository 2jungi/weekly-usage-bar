# Claude Weekly Usage Bar

Claude Code의 **주간 잔여 % → Claude 아이콘**을 Mac 메뉴바에 표시합니다.
기존 Codex용 Weekly Usage와 별개로 실행할 수 있습니다. [English](README.en.md)

## 설치

1. [최신 릴리스](https://github.com/2jungi/weekly-usage-bar/releases/latest)에서 **`Claude-Weekly-Usage-Mac-Installer.zip`**을 받고 압축을 풉니다. GitHub의 `Source code (zip)`은 설치 파일이 아닙니다.
2. `Claude Weekly Usage` 폴더 안의 **`install.command`를 더블클릭**합니다.
3. 완료되면 터미널 창을 닫습니다. 메뉴바에 주간 잔액이 나타나며 다음 로그인부터 자동 실행됩니다.

Apple Silicon / Intel 공용 앱이며 macOS 13 이상을 대상으로 빌드했습니다.
실제 실행 검증은 Apple Silicon / macOS 26.2에서 수행했습니다.
다른 OS 버전과 Intel은 실제 기기 검증을 하지 않았습니다.

**Claude Code를 별도로 설치하고 구독 계정으로 로그인해야 합니다.**
[공식 설치 안내](https://code.claude.com/docs/en/overview)를 참고하세요.
API 키 방식의 종량제 사용량은 표시하지 않습니다. Claude 데스크톱에만 로그인되어
있고 Claude Code에는 로그인되어 있지 않으면 조회할 수 없습니다.

## 화면에서 볼 수 있는 것

- 메뉴바: 전체 주간 한도의 남은 비율. 사용률 78%이면 `22%`입니다.
- 메뉴 클릭: 주간 사용률, 주간 초기화 시각, 5시간 한도의 잔액·초기화 시각.
- 약 **5분마다 자동 조회**, 잠자기 해제 후 조회, 수동 새로고침.
- 조회 간격은 최소 1분입니다. 서버가 조회 제한을 응답하면 최소 5분 또는
  서버가 지정한 시간까지 대기합니다.
- 날짜와 시간은 현재 Mac의 시간대입니다. 한국어·영어 메뉴를 지원합니다.

주간 잔액이 남아 있어도 5시간 한도를 다 쓰면 당장 사용할 수 없을 수 있습니다.
두 한도를 합산하거나 모델별 한도를 전체 주간 한도로 대체하지 않습니다.
조회 실패·오래된 정보·초기화 시각 경과 시 메뉴바는 `--%`를 표시합니다.

## 로그인과 키체인

앱은 현재 사용자의 `Claude Code-credentials` 키체인 항목에서 기존 로그인 토큰을
메모리로 읽습니다. Claude Code가 파일 저장 방식을 사용하는 경우에는 해당 설정
폴더의 `.credentials.json`을 읽습니다. 키체인 접근 요청이 나타나면 이 앱의
사용량 조회에 허용할지 선택할 수 있습니다. 거부하면 잔액을 읽지 못할 수 있습니다.

만료된 인증은 **공식 Claude Code의 로컬 `/usage` 명령을 실행하여 갱신**을 시도합니다.
앱이 직접 refresh token을 교체하거나 인증 저장소를 수정하지 않습니다.
확인한 Claude Code 2.1.116에서는 이 명령이 비대화형 환경에서 화면을 제공하지
않더라도 시작 시 인증을 갱신하며, 모델 API 토큰·비용은 0으로 확인했습니다.
갱신이 안 되면 Claude Code를 열고 다시 로그인한 뒤 새로고침하세요.

자동 갱신에 쓰는 CLI 탐색 위치는 `~/.local/bin/claude`, `/opt/homebrew/bin/claude`,
`/usr/local/bin/claude`입니다. 기본 Claude Code 프로필을 사용합니다.
`CLAUDE_CONFIG_DIR`는 앱 실행 환경에 직접 전달된 경우에만 반영됩니다.

## 첫 실행이 차단되는 경우

이 개인용 빌드는 Apple 공증을 받지 않았습니다. 파일을 한 번 열려고 시도한 뒤
**시스템 설정 → 개인정보 보호 및 보안 → 그래도 열기**에서 해당 파일만 허용할 수
있습니다. [Apple 공식 안내](https://support.apple.com/ko-kr/102445)를 참고하세요.
설치 도구는 Gatekeeper를 끄거나 격리 속성을 제거하지 않습니다.

## 데이터 연결과 개인정보

사용량은 설치된 Claude Code 2.1.116이 사용하는
`https://api.anthropic.com/api/oauth/usage` 조회 경로에서 읽습니다.
**외부 앱용으로 보장된 공개 API 계약이 아니므로 향후 변경되거나 제한될 수 있습니다.**
계정 사용량의 의미는 [공식 도움말](https://support.claude.com/en/articles/11647753-how-do-usage-and-length-limits-work)을 참고하세요.

- 인증 정보는 Anthropic의 위 HTTPS 주소에만 전송하며 리디렉션을 거부합니다.
- 앱 자체는 인증 정보를 파일로 저장하거나 다른 Mac에 복사하지 않습니다.
- 분석·광고·추적 서버가 없습니다. 기본 실행에서는 사용량 로그도 저장하지 않습니다.
- 인증 갱신 시 실행하는 Claude Code 자체의 인증 저장·로그 동작은 해당 도구의 정책을 따릅니다.
- 설치 ZIP에는 인증 정보나 공식 로고 파일이 없습니다. 로고는 별도로 설치된
  `/Applications/Claude.app` 또는 `~/Applications/Claude.app`에서 읽습니다.
  찾지 못하면 기본 macOS 사용량 아이콘을 표시합니다.

## 문제 해결

`--%`가 표시되면 메뉴의 상태 메시지를 확인하고 인터넷, Claude Code 로그인,
키체인 접근 상태를 점검하세요. ‘서버 조회 제한’이면 안내된 시간까지 기다리세요.

터미널에서 연결만 확인할 수도 있습니다.

```sh
"$HOME/Applications/Claude Weekly Usage.app/Contents/MacOS/ClaudeWeeklyUsage" --check
```

실행 파일은 `~/Applications/Claude Weekly Usage.app`, 자동 실행 설정은
`~/Library/LaunchAgents/io.github.2jungi.claude-weekly-usage-bar.plist`에 설치됩니다.
업데이트는 새 ZIP의 `install.command`를 다시 실행하세요. 이전 앱은 날짜가 붙은
이름으로 보관합니다. **`uninstall.command`를 실행하면 앱과 자동 실행 설정을
휴지통으로 옮깁니다.** Claude Code와 기존 Codex용 메뉴바 앱은 그대로 유지됩니다.

## 소스와 라이선스

저장소를 처음 받았다면 다음 명령으로 Claude 앱 폴더에 들어갑니다.

```sh
git clone https://github.com/2jungi/weekly-usage-bar.git
cd weekly-usage-bar/claude
./scripts/test.sh
./scripts/package.sh
./scripts/test-package.sh
```

빌드에는 Xcode Command Line Tools가 필요합니다. 결과는 `dist/`에 생성됩니다.
소스와 문서는 [MIT 라이선스](LICENSE)입니다. Claude 및 Anthropic의 이름과 로고,
Apple 시스템 자산은 이 라이선스에 포함되지 않습니다. 이 앱은 Anthropic의 공식
제품이 아니며 제휴·승인을 나타내지 않습니다. [별도 고지](THIRD_PARTY_NOTICES.md)를 확인하세요.
