#!/bin/zsh
set -euo pipefail
root=${0:A:h:h}
cd "$root"
mkdir -p .build
xcrun swiftc Sources/UsageSnapshot.swift Tests/main.swift -o .build/quota-tests
.build/quota-tests
for script in scripts/*.sh packaging/*.command; do zsh -n "$script"; done
plutil -lint packaging/Info.plist
print -- "PASS: shell syntax and app metadata"
