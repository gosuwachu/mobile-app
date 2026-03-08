#!/bin/bash
set -euo pipefail

echo "=== Android Linter ===" >&2
echo "Simulating: ./gradlew lint" >&2
sleep 2
echo "Lint found 0 errors, 0 warnings." >&2
