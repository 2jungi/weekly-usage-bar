#!/bin/zsh
set -euo pipefail
root=${0:A:h:h}
cd "$root"
mkdir -p .build/universal
app="$root/.build/Claude Weekly Usage.app"
mkdir -p "$app/Contents/MacOS"
for arch in arm64 x86_64; do
  xcrun swiftc -swift-version 5 -O -target "$arch-apple-macosx13.0" \
    -framework AppKit Sources/*.swift -o ".build/universal/ClaudeWeeklyUsage-$arch"
done
cp packaging/Info.plist "$app/Contents/Info.plist"
xcrun lipo -create .build/universal/ClaudeWeeklyUsage-arm64 .build/universal/ClaudeWeeklyUsage-x86_64 \
  -output "$app/Contents/MacOS/ClaudeWeeklyUsage"
codesign --force --sign - "$app"
codesign --verify --strict --all-architectures "$app"
print -- "Built: $app"
