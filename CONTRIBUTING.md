# Contributing

Bug reports, documentation improvements, and pull requests are welcome.

## Development

Use a Mac with Xcode Command Line Tools (`xcode-select --install` if needed).
No package manager or third-party library is required to build the app.

```sh
./scripts/test.sh
./scripts/build.sh
open '.build/Weekly Usage.app'
```

Running the app requires a separately installed and authenticated Codex runtime.
Parser tests do not require a login or network connection.
Quit an already-running installed copy before opening a development build.

## Code layout

| File | Responsibility |
| --- | --- |
| `Sources/UsageSnapshot.swift` | Select and validate the weekly Codex quota. |
| `Sources/UsageReader.swift` | Initialize the local Codex app-server connection and read limits. |
| `Sources/LocalAssets.swift` | Read an installed service icon or request the system fallback. |
| `Sources/Localization.swift` | Choose Korean or English UI text. |
| `Sources/main.swift` | Menu bar lifecycle, refresh, and error display. |
| `packaging/` | App metadata and per-user install/uninstall tools. |
| `scripts/` | Tests, universal build, and release packaging. |

Before a pull request, run `./scripts/test.sh` and build both architectures.
If changing installation behavior, validate it in a disposable directory using
`install.command --prepare-only /absolute/test/path`. This copies files and
creates the login plist under that path, but does not start or stop real apps.
`uninstall.command` accepts the same test option and moves only those test
files to the test root's `.Trash`. Never use your real home directory for tests.

Explain what changed and how you checked it. Keep unrelated changes separate.
Add tests for behavior changes such as quota selection and missing data.
Do not commit credentials, personal logs, compiled apps, or third-party artwork.
Contributions to original project code and documentation use the project's MIT
license; third-party rights remain separate.

## Releases

Update `packaging/Info.plist`, the reader's client version, and `CHANGELOG.md`.
Run `./scripts/test.sh`, `./scripts/package.sh`, and `./scripts/test-package.sh`, inspect the ZIP, then attach
the ZIP and its generated `SHA256SUMS.txt` to a GitHub release.
The signing step is ad-hoc signing; it is not notarization or a Developer ID.
Do not describe untested OS/CPU combinations as runtime-verified.

## Reporting safely

Describe the behavior and provide a minimal reproduction. Never include
`auth.json`, tokens, account identifiers, or private conversations in public
issues or screenshots. Please avoid posting exploitation details for a security
issue before maintainers can assess it; begin with a non-sensitive issue asking
to arrange private disclosure.
