#!/bin/bash
set -euo pipefail

echo "=== Android UI Tests ===" >&2
echo "Simulating: ./gradlew connectedDebugAndroidTest" >&2
sleep 5
echo "10 tests completed, 0 failed." >&2
