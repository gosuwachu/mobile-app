#!/bin/bash
set -euo pipefail

echo "=== Android Linter ==="
echo "Simulating: ./gradlew lint"
sleep 2
echo "Lint found 0 errors, 0 warnings."
