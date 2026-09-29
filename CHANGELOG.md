# Changelog

## Unreleased

- Move Codex source, tests, build scripts, and installer files under `codex/`,
  matching the Claude component layout. Build Codex with `./codex/scripts/build.sh`
  and package it with `./codex/scripts/package.sh`; artifacts now go to `codex/dist/`.
- Update both README build instructions and contributor documentation. This is a
  repository layout change; application behavior and installed paths are unchanged.

## 1.3.0 — 2026-09-28

Repository release containing Codex app 1.2.0 and Claude app 1.0.0.
Codex application behavior is unchanged; its packaged instructions are now
maintained in `docs/codex.md` and `docs/codex.en.md`.

- Add the independent Claude Code companion under `claude/`, with its own installer.
- Display overall Claude weekly quota remaining, with five-hour details in the menu.
- Refresh approximately every five minutes and honor server rate-limit cooldowns.
- Read existing Claude Code authentication locally; renewal is delegated to the
  official CLI. The internal usage endpoint may change without compatibility guarantees.
- Keep both apps' installation paths and login items separate so they can run together.
- Add bilingual app selection, installation guides, and Anthropic trademark notices.
- Distribute both universal installer ZIPs with a combined SHA-256 checksum file.

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
