#!/bin/bash
set -euo pipefail

echo "=== iOS Build ===" >&2
echo "Simulating: xcodebuild -project App.xcodeproj -scheme App -configuration Debug build" >&2
sleep 1
echo "Build succeeded." >&2
