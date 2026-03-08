#!/bin/bash
set -euo pipefail

echo "=== iOS Build ==="
echo "Simulating: xcodebuild -project App.xcodeproj -scheme App -configuration Debug build"
sleep 3
echo "Build succeeded."
