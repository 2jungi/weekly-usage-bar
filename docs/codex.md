# Weekly Usage Bar

**Codex 주간 한도 잔액을 Mac 메뉴바에서 바로 확인하세요.**

[English](https://github.com/2jungi/weekly-usage-bar/blob/main/docs/codex.en.md) · [설치 파일 다운로드](https://github.com/2jungi/weekly-usage-bar/releases/latest) · [문제 신고](https://github.com/2jungi/weekly-usage-bar/issues) · [MIT 라이선스](https://github.com/2jungi/weekly-usage-bar/blob/main/LICENSE)

```text
메뉴바:  44%  [서비스 아이콘]
         ↑
      남은 주간 한도
```

앱을 매번 열지 않아도 남은 한도를 확인할 수 있는 작은 macOS 메뉴바 앱입니다.
숫자 다음에 서비스 아이콘이 표시되며, 클릭하면 다음 초기화 시각과 마지막 조회 시각을 볼 수 있습니다.
**OpenAI가 만든 공식 앱이 아닌 독립적인 오픈소스 프로젝트**입니다.

## 주요 기능

- **잔여 비율 먼저:** 사용률 56%이면 `44%`를 표시합니다.
- **자동 갱신:** 약 1분마다, 잠자기에서 깨어날 때, 메뉴에서 새로고침할 때 조회합니다.
- **로그인 시 실행:** 설치 도구가 현재 사용자의 자동 실행 설정을 만듭니다.
- **한국어·영어 메뉴:** macOS의 우선 언어가 한국어이면 한국어, 그 외에는 영어로 표시합니다.
- **가벼운 네이티브 앱:** Swift/AppKit으로 작성했으며 Dock 아이콘을 띄우지 않습니다.
- **현재 상태를 구분:** 조회 실패·오래된 값·초기화 시각 경과 시 `--%`를 표시합니다. 메뉴의 과거 값은 마지막 확인 값으로 표시합니다.

## 시작 전 확인

| 항목 | 요구 사항 |
| --- | --- |
| 운영체제 | macOS 13 Ventura 이상을 대상으로 빌드한 앱입니다. |
| 칩 | Apple Silicon과 Intel 공용 바이너리를 제공합니다. |
| Codex | 공식 Codex 앱 또는 CLI가 **별도로 설치되고 ChatGPT 계정으로 로그인**되어 있어야 합니다. |
| 계정 | 서비스에서 Codex 주간 한도 정보를 제공해야 합니다. API 키만 사용하는 설정에서는 이 잔액을 조회할 수 없습니다. |
| 인터넷 | 사용량을 갱신할 때 필요합니다. |

실제 앱 실행과 조회는 **Apple Silicon / macOS 26.2**에서 검증했습니다. Intel 및 macOS 13–25는 빌드 대상으로 지원하지만 실제 기기 검증은 하지 않았습니다. 별도로 설치하는 Codex의 시스템 요구 사항도 충족해야 합니다. Windows와 Linux에서는 실행되지 않습니다.

Codex가 없다면 [공식 설치 안내](https://developers.openai.com/codex/cli/)를 먼저 따라 설치하고 로그인하세요. Codex 실행 파일을 포함한 ChatGPT 데스크톱 앱도 인식합니다. **일반 ChatGPT 앱에 Codex가 포함되어 있지 않다면 그것만 설치해서는 사용할 수 없습니다.**

## 설치 — 코딩 도구가 필요하지 않습니다

1. [최신 릴리스](https://github.com/2jungi/weekly-usage-bar/releases/latest)에서 **`Weekly-Usage-Mac-Installer.zip`**을 받습니다. GitHub가 자동으로 제공하는 `Source code (zip)`은 설치 파일이 아닙니다.
2. ZIP을 더블클릭하여 완전히 압축을 풉니다.
3. `Weekly Usage` 폴더의 **`install.command`를 더블클릭**합니다. 터미널 창이 열리고 앱과 자동 실행 설정을 설치합니다.
4. 설치 완료 후 터미널 창을 닫습니다. 메뉴바에 `잔여 % → 아이콘`이 나타납니다.

파일 복사에는 관리자 권한이 필요하지 않습니다. 앱은 `~/Applications/Weekly Usage.app`에 설치되며, 다음 로그인부터 자동 실행됩니다. 사용자 이름이 다르거나 경로에 공백·한글이 있어도 설치할 수 있습니다.

### 처음 실행할 때 macOS가 차단한다면

공개 빌드는 로컬 서명(ad-hoc)만 적용했으며 **Apple 개발자 인증서 서명과 공증을 받지 않았습니다**. macOS가 `install.command` 또는 앱의 개발자를 확인할 수 없다고 표시할 수 있습니다.

이 저장소에서 받은 파일인지 확인한 뒤, 해당 파일을 한 번 열려고 시도하고 **시스템 설정 → 개인정보 보호 및 보안 → 그래도 열기**에서 해당 파일만 허용하세요. macOS가 로그인을 요구할 수 있습니다. 자세한 절차는 [Apple 공식 안내](https://support.apple.com/ko-kr/102445)를 참고하세요. 조직에서 관리하는 Mac은 실행을 허용하지 않을 수 있습니다.

이 설치 도구는 Gatekeeper를 끄거나 다운로드 격리 속성을 지우지 않습니다.

## 사용 방법

메뉴바 항목을 클릭하면 다음을 볼 수 있습니다.

- 주간 잔여 비율과 사용 비율
- 다음 초기화 날짜·시간 — **사용 중인 Mac의 현지 시간**
- 마지막 조회 시각
- 지금 새로고침 / ChatGPT·Codex 열기 / 종료

앱을 종료해도 다음 로그인 시에는 다시 실행됩니다. 지금 다시 열려면 Finder에서 **이동 → 폴더로 이동**을 선택하고 `~/Applications`를 입력한 뒤 `Weekly Usage.app`을 여세요.

### 무엇을 계산하나요?

[공식 Codex App Server](https://learn.chatgpt.com/docs/app-server)의 `account/rateLimits/read` 응답에서 `codex` 항목의 **10,080분(7일)** 구간을 찾고 `100 − usedPercent`를 계산합니다. 소수점은 내려 표시하며 0–100% 범위로 제한합니다.

짧은 시간 구간의 한도, 일반 ChatGPT 메시지 한도, 예비 모델의 별도 한도를 합산하지 않습니다. 한도 정보가 없으면 `0%` 또는 `100%`로 추정하지 않습니다. 같은 계정을 쓰는 여러 Mac의 사용량은 계정 단위로 공유됩니다.

### 아이콘은 어디에서 오나요?

설치된 공식 ChatGPT/Codex 앱에 메뉴바 로고가 있으면 해당 자산을 런타임에 읽어 표시합니다. **이 저장소와 공개 설치 ZIP에는 OpenAI 로고 파일이 들어 있지 않습니다.** 해당 자산이 없으면 macOS 기본 사용량 아이콘을 표시하며, 잔액 조회 기능은 동일합니다. 권리 관계는 [제3자 고지](https://github.com/2jungi/weekly-usage-bar/blob/main/THIRD_PARTY_NOTICES.md)를 참고하세요.

## 문제가 생겼나요?

| 증상 | 확인할 내용 |
| --- | --- |
| `--%`가 보입니다 | 메뉴의 상태 메시지를 확인하세요. 인터넷과 Codex 로그인 상태를 확인하고 `지금 새로고침`을 선택하세요. |
| Codex를 찾을 수 없다고 합니다 | 공식 앱을 `/Applications` 또는 `~/Applications`에 설치하세요. CLI는 `/opt/homebrew/bin/codex`, `/usr/local/bin/codex`, `~/.local/bin/codex`를 확인합니다. 사용자 지정 경로나 버전 관리자만의 경로는 자동 탐색하지 않습니다. |
| 로그인했는데 한도가 안 보입니다 | Codex의 ChatGPT 계정 로그인인지 확인하세요. API 키 인증, 주간 구간 미제공 계정, 서비스 응답 변경은 조회할 수 없을 수 있습니다. |
| 로고 대신 다른 아이콘이 보입니다 | 공식 앱의 로고 자산을 찾지 못한 경우입니다. 정상적인 대체 표시입니다. |
| 메뉴바에 안 보입니다 | 앱을 다시 열고, macOS 메뉴바 자동 숨김이나 다른 메뉴바 관리 앱이 항목을 숨겼는지 확인하세요. |
| 다운로드한 파일이 열리지 않습니다 | ZIP을 먼저 풀었는지와 위의 첫 실행 안내를 확인하세요. |

개발자용 연결 확인 명령도 있습니다. 이 명령은 모델 대화를 만들지 않고 사용량을 조회합니다.

```sh
"$HOME/Applications/Weekly Usage.app/Contents/MacOS/WeeklyUsage" --check
```

문제가 계속되면 [이슈](https://github.com/2jungi/weekly-usage-bar/issues)에 macOS 버전, 칩, 앱 버전, 상태 메시지를 남겨주세요. **인증 토큰, `auth.json`, 계정 이메일, 개인 대화 내용은 올리지 마세요.**

## 업데이트와 제거

**업데이트:** 새 릴리스의 ZIP을 풀고 `install.command`를 다시 실행하세요. 기존 앱을 종료한 뒤 새 버전을 설치하며, 이전 앱은 `~/Applications`에 날짜가 붙은 이름으로 보관합니다. 자동 업데이트 기능은 없습니다.

**제거:** 배포 폴더의 `uninstall.command`를 실행하면 앱과 자동 실행 설정을 휴지통으로 옮깁니다. ChatGPT/Codex 설치와 로그인 정보는 건드리지 않습니다. 과거 업데이트에서 보관한 이전 버전 앱은 필요한 경우 별도로 휴지통에 옮기세요.

설치되는 파일은 다음 두 가지입니다.

```text
~/Applications/Weekly Usage.app
~/Library/LaunchAgents/io.github.2jungi.weekly-usage-bar.plist
```

## 개인정보와 네트워크

- 이 프로젝트 자체의 분석 수집, 광고, 추적 서버는 없습니다.
- 인증 토큰을 직접 읽거나 다른 장치로 복사하지 않습니다. **설치된 공식 Codex가 기존 로그인 상태로 조회**합니다.
- 응답은 메모리에 보관하며, 이 공개 버전은 계정 정보나 사용량 로그 파일을 따로 저장하지 않습니다.
- Codex 실행 파일은 OpenAI 서비스와 통신합니다. Codex 자체의 인증·로그·네트워크 동작은 해당 소프트웨어의 설정과 정책을 따릅니다.
- 한도 조회만 요청하며 모델 프롬프트, 새 대화, 결제 또는 한도 초기화 요청을 보내지 않습니다.

## 직접 빌드하고 기여하기

macOS와 Xcode Command Line Tools가 필요합니다. 빌드에는 별도 패키지 다운로드가 필요하지 않습니다.

```sh
git clone https://github.com/2jungi/weekly-usage-bar.git
cd weekly-usage-bar
./scripts/test.sh
./scripts/package.sh
```

결과는 `dist/Weekly-Usage-Mac-Installer.zip`과 `dist/SHA256SUMS.txt`에 만들어집니다. 앱만 빌드하려면 `./scripts/build.sh`를 실행하세요. 개발 방법과 기여 절차는 [CONTRIBUTING.md](https://github.com/2jungi/weekly-usage-bar/blob/main/CONTRIBUTING.md)를 참고하세요.

## 라이선스

이 프로젝트의 소스와 문서는 **[MIT 라이선스](https://github.com/2jungi/weekly-usage-bar/blob/main/LICENSE)**로 제공됩니다. 고지를 유지하는 조건으로 사용·수정·재배포할 수 있으며 소프트웨어는 보증 없이 제공됩니다.

**MIT 라이선스는 OpenAI·ChatGPT·Codex 명칭과 로고, Apple 자산, 별도로 설치하는 공식 소프트웨어에 대한 권리를 부여하지 않습니다.** 이 프로젝트는 OpenAI 또는 Apple과 제휴하거나 그들의 승인을 받은 제품이 아닙니다. [제3자 고지 및 상표 안내](https://github.com/2jungi/weekly-usage-bar/blob/main/THIRD_PARTY_NOTICES.md)를 함께 확인하세요.
