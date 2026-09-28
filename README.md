# Weekly Usage Bar

**Codex와 Claude Code의 주간 한도 잔액을 Mac 메뉴바에서 확인하세요.**

[English](README.en.md) · [설치 파일 다운로드](https://github.com/2jungi/weekly-usage-bar/releases/latest) · [문제 신고](https://github.com/2jungi/weekly-usage-bar/issues) · [MIT 라이선스](LICENSE)

두 개의 독립적인 메뉴바 앱을 제공합니다. 필요한 앱만 설치하거나 둘 다 함께 사용할 수 있습니다.
각 앱은 **남은 비율 % → 서비스 아이콘** 순서로 표시하며, 클릭하면 한도와 초기화 시각을 보여줍니다.
OpenAI 또는 Anthropic이 만든 공식 앱이 아닌 커뮤니티 프로젝트입니다.

## 사용할 앱 선택

| | Codex용 | Claude Code용 |
| --- | --- | --- |
| 설치 파일 | [Weekly-Usage-Mac-Installer.zip](https://github.com/2jungi/weekly-usage-bar/releases/latest/download/Weekly-Usage-Mac-Installer.zip) | [Claude-Weekly-Usage-Mac-Installer.zip](https://github.com/2jungi/weekly-usage-bar/releases/latest/download/Claude-Weekly-Usage-Mac-Installer.zip) |
| 설치되는 앱 | `Weekly Usage.app` | `Claude Weekly Usage.app` |
| 필요한 로그인 | 별도로 설치한 Codex에서 ChatGPT 계정 로그인 | 별도로 설치한 Claude Code에서 구독 계정 로그인 |
| 메뉴바 표시 | Codex 전체 주간 잔액 | Claude 전체 주간 잔액 |
| 자동 갱신 | 약 1분 | 약 5분, 서버 조회 제한 시 대기 |
| 클릭 메뉴 | 주간 사용률·잔액·초기화 시각 | 주간 정보와 5시간 한도·초기화 시각 |
| 상세 안내 | [Codex 설치·사용법](docs/codex.md) | [Claude Code 설치·사용법](claude/README.md) |
| 소스 위치 | [`Sources/`](Sources) | [`claude/Sources/`](claude/Sources) |

## 설치 — 코딩 도구가 필요하지 않습니다

1. 위 표에서 원하는 **설치 ZIP**을 받습니다. GitHub의 `Source code (zip)`은 설치 파일이 아닙니다.
2. ZIP을 완전히 풀고 폴더 안의 **`install.command`를 더블클릭**합니다.
3. 설치 완료 후 터미널 창을 닫습니다. 다음 Mac 로그인부터 자동 실행됩니다.
4. 다른 서비스도 표시하려면 그 앱의 ZIP으로 같은 과정을 진행합니다.

앱은 현재 사용자의 `~/Applications`에 설치됩니다. 두 앱은 서로 다른 이름과 자동 실행 설정을 사용합니다.
각 ZIP에는 설치·제거 도구, 한국어·영어 사용 안내, MIT 라이선스와 제3자 권리 고지가 들어 있습니다.
업데이트는 새 ZIP의 설치 도구를 다시 실행하고, 제거는 해당 앱의 `uninstall.command`를 실행하세요.

**macOS 13 이상 / Apple Silicon·Intel 공용 빌드**입니다. 실제 기기 검증은 Apple Silicon / macOS 26.2에서 수행했습니다.
Windows와 Linux에서는 실행되지 않습니다. API 키만 사용하는 종량제 계정의 잔액은 표시하지 않습니다.

### 처음 실행할 때 macOS가 차단한다면

공개 빌드는 **Apple 개발자 인증서 서명과 공증을 받지 않았습니다.** 파일을 한 번 열려고 시도한 뒤
**시스템 설정 → 개인정보 보호 및 보안 → 그래도 열기**에서 해당 파일만 허용하세요.
[Apple 공식 안내](https://support.apple.com/ko-kr/102445)를 참고하세요.
설치 도구는 Gatekeeper를 끄거나 격리 속성을 지우지 않습니다.

## 로그인·개인정보·아이콘

- **Codex:** 설치된 공식 Codex App Server가 기존 로그인으로 한도를 조회합니다. 이 앱은 인증 토큰을 직접 읽지 않습니다.
- **Claude Code:** 기존 Claude Code의 키체인 또는 인증 파일을 메모리로 읽어 Anthropic의 사용량 조회 주소에만 전송합니다. 만료된 인증은 공식 Claude Code로 갱신을 시도합니다. [인증 방식과 제한 사항](claude/README.md#로그인과-키체인)을 먼저 확인하세요.
- Claude 조회 경로는 외부 앱용으로 보장된 공개 API가 아니며, 향후 서비스 변경으로 동작하지 않을 수 있습니다.
- 앱 자체의 광고·추적 서버는 없으며, 기본 실행에서는 사용량 로그를 따로 저장하지 않습니다. 각 공식 도구 자체의 동작은 해당 설정과 정책을 따릅니다.
- 저장소와 설치 ZIP에는 계정 정보, 공식 실행 파일 또는 로고 파일을 포함하지 않습니다. 로고는 별도로 설치된 공식 앱에서 읽고, 찾지 못하면 macOS 기본 아이콘을 표시합니다.
- 조회할 수 없거나 값이 오래되면 `--%`를 표시합니다. 로그인 방법과 문제 해결은 각 앱의 상세 안내를 참고하세요.

## 직접 빌드하기

macOS와 Xcode Command Line Tools가 필요합니다. 별도 패키지 다운로드 없이 빌드합니다.

```sh
git clone https://github.com/2jungi/weekly-usage-bar.git
cd weekly-usage-bar

# Codex용
./scripts/test.sh
./scripts/package.sh
./scripts/test-package.sh

# Claude Code용
./claude/scripts/test.sh
./claude/scripts/package.sh
./claude/scripts/test-package.sh
```

Codex 설치 파일은 `dist/`, Claude 설치 파일은 `claude/dist/`에 생성됩니다.
개발과 배포 절차는 [기여 안내](CONTRIBUTING.md)를 참고하세요.

## 라이선스

원본 소스와 문서는 **[MIT 라이선스](LICENSE)**로 제공합니다.
OpenAI·ChatGPT·Codex·Anthropic·Claude의 이름과 로고, Apple 자산 및 별도 공식 소프트웨어는 MIT 라이선스에 포함되지 않습니다.
이 프로젝트는 해당 회사들과 제휴하거나 그들의 승인을 받은 제품이 아닙니다.
[제3자 고지](THIRD_PARTY_NOTICES.md)와 [Claude 앱 고지](claude/THIRD_PARTY_NOTICES.md)를 함께 확인하세요.
