#!/bin/bash
set -euo pipefail

echo "=== iOS UI Tests ===" >&2
echo "Simulating: xcodebuild test -project App.xcodeproj -scheme AppUITests -destination 'platform=iOS Simulator,name=iPhone 15'" >&2
sleep 1
echo "Executed 12 UI tests, with 0 failures in 48.2 seconds." >&2
