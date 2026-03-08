#!/bin/bash
set -euo pipefail

echo "=== iOS Linter ===" >&2
echo "Simulating: swiftlint lint --strict" >&2
sleep 1
echo "Linting passed. No violations found." >&2
