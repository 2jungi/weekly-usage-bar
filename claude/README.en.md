# Claude Weekly Usage Bar

Display **weekly quota remaining % → Claude icon** in your Mac's menu bar.
Runs independently alongside the Codex Weekly Usage app. [한국어](README.md)

## Install

Download **`Claude-Weekly-Usage-Mac-Installer.zip`** from [the latest release](https://github.com/2jungi/weekly-usage-bar/releases/latest), extract it, and double-click `install.command`.
GitHub's automatically generated source-code ZIP is not an installer.
The app is installed in `~/Applications` and starts automatically at your next login.
Double-click `uninstall.command` to move this app and its login item to Trash.
Neither tool removes Claude Code, its credentials, or the Codex menu bar app.

The universal binary targets Apple Silicon / Intel on macOS 13+. Runtime validation
was performed on Apple Silicon/macOS 26.2 only. Builds are ad-hoc signed and are
not Apple-notarized. For a first-launch block, follow [Apple's per-app instructions](https://support.apple.com/102445).
The installer does not disable Gatekeeper or strip quarantine attributes.

## Requirements and behavior

Install [Claude Code](https://code.claude.com/docs/en/overview) separately and sign in
with a subscription account. Claude desktop sign-in alone is insufficient; API-key
billing is not supported. If Keychain asks for access, allow it only if you want this
app to read your Claude Code credentials for the usage request.

The menu bar displays `100 − seven_day.utilization`, rounded down and clamped to
0–100%. Click to see the five-hour quota and reset times as well. A positive weekly
balance does not mean the five-hour quota has capacity. Model-specific quotas are
not substituted for the overall weekly quota.

Refreshes every five minutes, after wake, and manually. Requests are at least one
minute apart. Rate limiting triggers a cooldown of at least five minutes and respects
the server's Retry-After value. Missing, failed, stale, or expired data shows `--%`.

## Authentication and privacy

This app reads your existing `Claude Code-credentials` Keychain item, or Claude Code's
`.credentials.json` fallback, into memory. It sends the access token only to
`https://api.anthropic.com/api/oauth/usage`; redirects are refused. This is an internal
Claude Code usage endpoint, not a guaranteed public API for third-party apps.

For expired credentials, the app invokes the official local `/usage` command so that
Claude Code refreshes its own authentication. In tested CLI version 2.1.116 the
non-interactive command returns an unavailable-screen message but refreshes login
on startup, with zero model API tokens and cost. Behavior can change in future CLI
versions. If refresh fails, sign in again in Claude Code. The app does not implement
refresh-token rotation itself.

CLI paths: `~/.local/bin/claude`, `/opt/homebrew/bin/claude`, `/usr/local/bin/claude`.
Uses the default profile unless `CLAUDE_CONFIG_DIR` is passed into this app's process
environment. Login-item launches do not inherit arbitrary shell configuration.

No analytics backend, credential export, or usage logs by default. Claude Code's own
authentication persistence and logging follow its settings. No credentials or Claude
logo files are bundled. A compatible icon is read from your separately installed
official Claude app, or a macOS usage symbol is used as fallback.

## Troubleshooting and building

For `--%`, read the menu status and check network, Claude Code sign-in, and Keychain
access. For a rate-limit message, wait for the cooldown. A read-only connection check:

```sh
"$HOME/Applications/Claude Weekly Usage.app/Contents/MacOS/ClaudeWeeklyUsage" --check
```

Build with Xcode Command Line Tools:

```sh
git clone https://github.com/2jungi/weekly-usage-bar.git
cd weekly-usage-bar/claude
./scripts/test.sh
./scripts/package.sh
./scripts/test-package.sh
```

Source and docs use the [MIT license](LICENSE). Third-party logos, trademarks and
software are excluded. This is an independent app, not an Anthropic product or
endorsement. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
