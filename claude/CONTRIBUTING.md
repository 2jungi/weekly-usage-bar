# Development

Build on macOS with Xcode Command Line Tools. Run `./scripts/test.sh` for offline
quota/cooldown tests, `./scripts/package.sh` for a universal ZIP, and
`./scripts/test-package.sh` for installation, upgrade, uninstall and collision checks.
Tests use disposable directories and do not change live login items or credentials.

`--check` reads real account usage. Never commit credentials, account responses or
Keychain output. Review any authentication changes carefully: tokens must never be
printed, written to logs, included in process arguments, or sent to another host.

An optional developer switch, `--diagnostic-file /absolute/path.json`, writes only
menu state, percentages and display visibility for UI verification. It is not enabled
in normal installation. Treat account usage as private and keep such output local.

The underlying usage endpoint is internal and may change. Do not claim support for
authentication modes or systems that have not been validated. Preserve third-party
notices and keep trademark artwork out of distributions.
