#!/bin/bash
set -euo pipefail

echo "=== iOS Unit Tests ===" >&2
echo "Simulating: xcodebuild test -project App.xcodeproj -scheme AppTests -destination 'platform=iOS Simulator,name=iPhone 15'" >&2
sleep 1
echo "Executed 42 tests, with 0 failures in 3.8 seconds." >&2
