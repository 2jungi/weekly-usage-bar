# Weekly Usage Bar

**See your remaining Codex weekly quota in the macOS menu bar.**

[한국어](README.md) · [Download](https://github.com/2jungi/weekly-usage-bar/releases/latest) · [Issues](https://github.com/2jungi/weekly-usage-bar/issues) · [MIT license](LICENSE)

```text
44%  [service icon]
 ↑
remaining weekly quota
```

A small native Swift/AppKit app that puts the remaining percentage **before** the service icon. Click it to see usage, the next reset time, and the last successful refresh. This is an **independent community project**, not an official OpenAI app.

## Features

- Refreshes approximately every minute, after waking your Mac, and on demand.
- Optional installation with automatic launch at your next login.
- English menus, or Korean when Korean is your preferred macOS language.
- No Dock icon and no bundled package dependencies.
- Shows `--%` when data is unavailable, outdated, or past its reset time. Last-known values in the menu are labeled accordingly.

## Requirements

- The app targets **macOS 13 Ventura or later**, with a universal Apple Silicon / Intel binary.
- Install the official **Codex desktop app or CLI separately**, then sign in with your **ChatGPT account**. See the [official CLI setup guide](https://developers.openai.com/codex/cli/).
- A ChatGPT desktop app that includes Codex is also detected. A standalone ChatGPT app without a Codex executable is not sufficient.
- The account must return a Codex weekly quota, and refreshing requires an internet connection. API-key-only authentication does not provide this balance.

Runtime and live quota retrieval have been tested on **Apple Silicon with macOS 26.2**. Intel and macOS 13–25 are build targets, not hardware-verified configurations. Your separately installed Codex runtime may have additional requirements. Windows and Linux are not supported.

## Install without building

1. Open [the latest release](https://github.com/2jungi/weekly-usage-bar/releases/latest) and download **`Weekly-Usage-Mac-Installer.zip`**, not GitHub's automatically generated source-code ZIP.
2. Double-click the ZIP to extract it fully.
3. In the `Weekly Usage` folder, double-click **`install.command`**. A Terminal window installs the app and its login item.
4. Close Terminal when installation finishes. The menu bar shows **remaining % → service icon**.

The installer uses your own home folder and does not require administrator access to copy files. The app is installed at `~/Applications/Weekly Usage.app` and starts automatically at your next login. The installer prints a bilingual completion message.

### First-launch security prompt

Public builds are **ad-hoc signed, not Developer ID signed or Apple-notarized**. macOS may block the installer or app because it cannot verify the developer.

After confirming that you downloaded the file from this repository, try opening it once, then use **System Settings → Privacy & Security → Open Anyway** for that specific file. macOS may ask for your login credentials. Follow [Apple's instructions](https://support.apple.com/102445). Managed Macs may prohibit this. The installer does not disable Gatekeeper or strip quarantine attributes.

## Using the app

Click the menu bar item for remaining/used percentages, the reset time in your Mac's local time zone, the last check time, refresh, open ChatGPT/Codex, and quit. Quitting stops it for this session; the login item starts it again at the next login.

To reopen it now, use Finder → Go → Go to Folder, enter `~/Applications`, and open `Weekly Usage.app`.

### What the number means

The app calls [`account/rateLimits/read` through the official Codex App Server](https://learn.chatgpt.com/docs/app-server), selects the `codex` bucket's **10,080-minute (7-day)** window, and displays `100 − usedPercent`, rounded down and clamped to 0–100%.

It does not add short-term quotas, general ChatGPT message limits, or reserve-model quotas. Missing data is never interpreted as zero or unlimited usage. Multiple Macs signed into the same account share that account's quota.

### Service icon

If your separately installed official ChatGPT/Codex app contains a compatible menu bar logo, Weekly Usage reads it at runtime without copying it. **The repository and public release ZIP do not contain OpenAI logo files.** Otherwise, it displays a built-in macOS usage symbol. Quota retrieval works with either icon. See [third-party notices](THIRD_PARTY_NOTICES.md).

## Troubleshooting

| Symptom | What to check |
| --- | --- |
| `--%` | Read the menu's status message, check your connection and Codex sign-in, then select Refresh now. |
| Codex not found | Official apps are searched in `/Applications` and `~/Applications`. CLI locations are `/opt/homebrew/bin/codex`, `/usr/local/bin/codex`, and `~/.local/bin/codex`. Arbitrary paths and version-manager-only paths are not searched. |
| Signed in, but no weekly quota | Check that Codex uses ChatGPT sign-in. The account might not expose a weekly window, or the service response may have changed. |
| Different icon | No compatible logo was found in an installed official app; the fallback is expected. |
| No menu bar item | Reopen the app and check menu bar auto-hide or third-party menu bar managers. |
| Download will not open | Extract the ZIP first and follow the first-launch section above. |

A connection check is available without starting a model conversation:

```sh
"$HOME/Applications/Weekly Usage.app/Contents/MacOS/WeeklyUsage" --check
```

When [reporting a bug](https://github.com/2jungi/weekly-usage-bar/issues), include your macOS version, chip, app version, and status message. **Do not post tokens, `auth.json`, account email addresses, or private conversations.**

## Update or uninstall

**Update:** Download a new release and run its `install.command`. It stops the existing app and keeps the previous version under a dated name in `~/Applications`. There is no automatic updater.

**Uninstall:** Run `uninstall.command` from the release folder. It moves the app and login item to Trash. Your Codex installation and sign-in are preserved. Previously backed-up app versions can be moved to Trash separately.

Installed files:

```text
~/Applications/Weekly Usage.app
~/Library/LaunchAgents/io.github.2jungi.weekly-usage-bar.plist
```

## Privacy

The project has no analytics, ads, or tracking backend. It does not directly read tokens or transfer credentials between Macs: the official local Codex runtime handles existing authentication and communicates with OpenAI. This public version holds quota responses in memory and writes no separate account or usage log. Codex's own authentication, logging, and network behavior remain governed by its settings and policies.

Only a quota read is requested: no model prompt, new conversation, payment, or quota-reset request is sent.

## Build from source

Requires macOS and Xcode Command Line Tools. No additional packages are downloaded during the build.

```sh
git clone https://github.com/2jungi/weekly-usage-bar.git
cd weekly-usage-bar
./scripts/test.sh
./scripts/package.sh
```

Outputs: `dist/Weekly-Usage-Mac-Installer.zip` and `dist/SHA256SUMS.txt`. For just the app, run `./scripts/build.sh`. See [CONTRIBUTING.md](CONTRIBUTING.md) for development and validation details.

## License

Project source and documentation are provided under the **[MIT license](LICENSE)**, including its notice-preservation requirement and warranty disclaimer.

The MIT license **does not grant rights to OpenAI, ChatGPT, or Codex names/logos, Apple assets, or separately installed third-party software**. This project is not affiliated with, endorsed by, or sponsored by OpenAI or Apple. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
