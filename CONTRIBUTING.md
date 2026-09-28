# Contributing

Bug reports, documentation improvements, and pull requests are welcome.

## Development

Use a Mac with Xcode Command Line Tools (`xcode-select --install` if needed).
No package manager or third-party library is required to build the app.

Codex source and build scripts remain at the repository root. The Claude Code
companion has an independent layout under `claude/`; see its
[development notes](https://github.com/2jungi/weekly-usage-bar/blob/main/claude/CONTRIBUTING.md)
for authentication precautions. Run the same commands prefixed with `./claude/`
to work on that app, for example `./claude/scripts/test.sh`.

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

Repository releases may contain different component versions: `v1.3.0` includes
Codex app 1.2.0 and Claude app 1.0.0. State both versions in release notes. Build
and validate each component from its own directory, then attach both installer
ZIPs and one combined `SHA256SUMS.txt`. For example, from the repository root:

```sh
./scripts/test.sh
./scripts/package.sh
./scripts/test-package.sh
./claude/scripts/test.sh
./claude/scripts/package.sh
./claude/scripts/test-package.sh
mkdir -p .build/release
cp dist/Weekly-Usage-Mac-Installer.zip .build/release/
cp claude/dist/Claude-Weekly-Usage-Mac-Installer.zip .build/release/
(cd .build/release && shasum -a 256 *.zip > SHA256SUMS.txt)
```

The landing READMEs describe both apps. Codex-specific guides are in `docs/` and
are copied into the Codex installer as its READMEs; Claude guides live in `claude/`.
Keep the English and Korean guides aligned with the corresponding component.

For application behavior changes, update that component's `packaging/Info.plist`,
reader client version, and `CHANGELOG.md`. Repository-only documentation changes
need not change component versions. Inspect both final ZIPs before publishing.
The signing step is ad-hoc signing; it is not notarization or a Developer ID.
Do not describe untested OS/CPU combinations as runtime-verified.

## Reporting safely

Describe the behavior and provide a minimal reproduction. Never include
`auth.json`, tokens, account identifiers, or private conversations in public
issues or screenshots. Please avoid posting exploitation details for a security
issue before maintainers can assess it; begin with a non-sensitive issue asking
to arrange private disclosure.
