#!/bin/bash
set -euo pipefail

echo "=== iOS Linter ==="
echo "Simulating: swiftlint lint --strict"
sleep 2
echo "Linting passed. No violations found."
