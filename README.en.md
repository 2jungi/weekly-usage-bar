# Weekly Usage Bar

**See your remaining Codex and Claude Code weekly quotas in the macOS menu bar.**

[한국어](README.md) · [Downloads](https://github.com/2jungi/weekly-usage-bar/releases/latest) · [Issues](https://github.com/2jungi/weekly-usage-bar/issues) · [MIT license](LICENSE)

Two independent menu bar apps: install either one or run both together.
Each displays **remaining % → service icon**; click for quota details and reset times.
This is a community project, not an official OpenAI or Anthropic product.

![Mac menu bar showing 34% Codex weekly quota remaining and 98% Claude weekly quota remaining](docs/assets/menu-bar-preview.png)

Both apps running together in a real Mac menu bar: **Codex on the left, Claude on the right**.
The percentages show the weekly balances when the screenshot was taken. Each app places the remaining percentage before its service icon.

## Choose your app

| | Codex | Claude Code |
| --- | --- | --- |
| Installer | [Weekly-Usage-Mac-Installer.zip](https://github.com/2jungi/weekly-usage-bar/releases/latest/download/Weekly-Usage-Mac-Installer.zip) | [Claude-Weekly-Usage-Mac-Installer.zip](https://github.com/2jungi/weekly-usage-bar/releases/latest/download/Claude-Weekly-Usage-Mac-Installer.zip) |
| Installed app | `Weekly Usage.app` | `Claude Weekly Usage.app` |
| Required sign-in | ChatGPT account in a separately installed Codex runtime | Subscription account in a separately installed Claude Code CLI |
| Menu bar | Overall Codex weekly quota remaining | Overall Claude weekly quota remaining |
| Refresh interval | About 1 minute | About 5 minutes, with server cooldown handling |
| Click for | Weekly usage, remaining quota, and reset time | Weekly details plus the five-hour quota and reset time |
| Full guide | [Codex installation and usage](docs/codex.en.md) | [Claude Code installation and usage](claude/README.en.md) |
| Source | [`codex/Sources/`](codex/Sources) | [`claude/Sources/`](claude/Sources) |

## Install without building

1. Download the **installer ZIP** for your service from the table above. GitHub's automatic source-code ZIP is not an installer.
2. Extract it fully and double-click **`install.command`** inside the extracted folder.
3. Close Terminal when installation finishes. The app starts automatically at your next Mac login.
4. To display both services, repeat with the other app's ZIP.

Apps install to your own `~/Applications` folder with distinct names and login items.
Each ZIP includes installation/uninstallation tools, English and Korean instructions, the MIT license, and third-party notices.
To update, run the new ZIP's installer; to uninstall, run that app's `uninstall.command`.

Universal builds target **macOS 13+ on Apple Silicon and Intel**. Runtime validation was performed on Apple Silicon/macOS 26.2 only.
Windows and Linux are not supported. API-key-only, pay-as-you-go accounts do not provide the displayed subscription quota.

### First-launch security prompt

Builds are **not Developer ID signed or Apple-notarized**. After trying to open the file once,
use **System Settings → Privacy & Security → Open Anyway** for that specific file.
See [Apple's instructions](https://support.apple.com/102445).
The installers do not disable Gatekeeper or strip quarantine attributes.

## Authentication, privacy, and icons

- **Codex:** The official, locally installed Codex App Server handles authentication and reads limits. This app does not directly read tokens.
- **Claude Code:** Reads existing Claude Code credentials from Keychain or its credential file into memory, then sends the access token only to Anthropic's usage endpoint. It attempts renewal through the official Claude Code CLI. Read the [authentication details and limitations](claude/README.en.md#authentication-and-privacy).
- Claude's usage endpoint is not a guaranteed public third-party API and may change or become unavailable.
- The apps have no advertising or tracking backend and write no separate usage logs in normal operation. Each official runtime's own behavior follows its settings and policies.
- No credentials, official executables, or standalone service artwork are distributed. Compatible service icons are read from separately installed official apps; otherwise a macOS system icon is used. The screenshot above includes service icons to illustrate the apps in use.
- Missing or stale data displays `--%`. See the app-specific guides for sign-in and troubleshooting.

## Build from source

Requires macOS and Xcode Command Line Tools. No extra packages are downloaded.

```sh
git clone https://github.com/2jungi/weekly-usage-bar.git
cd weekly-usage-bar

# Codex
./codex/scripts/test.sh
./codex/scripts/package.sh
./codex/scripts/test-package.sh

# Claude Code
./claude/scripts/test.sh
./claude/scripts/package.sh
./claude/scripts/test-package.sh
```

Codex artifacts go to `codex/dist/`; Claude artifacts go to `claude/dist/`.
See [CONTRIBUTING.md](CONTRIBUTING.md) for development and release instructions.

## License

Original source and documentation use the **[MIT license](LICENSE)**.
It does not license OpenAI, ChatGPT, Codex, Anthropic, or Claude names/logos, Apple assets, or separately installed official software.
This project is not affiliated with or endorsed by those companies.
See the [third-party notices](THIRD_PARTY_NOTICES.md) and [Claude-specific notices](claude/THIRD_PARTY_NOTICES.md).
