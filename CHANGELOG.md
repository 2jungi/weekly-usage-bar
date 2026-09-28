# Changelog

## 1.2.0 — 2026-09-28

First public source and binary release.

- Universal macOS build targeting Apple Silicon and Intel, macOS 13+.
- Remaining Codex weekly quota followed by a service icon in the menu bar.
- Automatic refresh, refresh after wake, and manual refresh.
- English and Korean menus and documentation.
- Per-user installer with login launch, upgrade backups, and an uninstaller.
- Official logo loaded locally when available; no OpenAI artwork bundled.
- Missing/expired data handling and tests for weekly vs. reserve/short quotas.
- MIT license for original code and documentation, with separate trademark notices.

Known limitations: builds are not Apple-notarized; runtime validation has been
performed on Apple Silicon/macOS 26.2 only. A supported, separately installed
Codex runtime and ChatGPT sign-in are required.
