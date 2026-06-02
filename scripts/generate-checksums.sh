#!/usr/bin/env bash
# Generate SHA256SUMS and SHA512SUMS for all non-checksum files in a directory.
# Usage: bash scripts/generate-checksums.sh <directory>
set -euo pipefail
DIR="${1:-.}"
cd "$DIR"
find . -maxdepth 1 -type f ! -name 'SHA*SUMS' -print0 | sort -z | xargs -0 sha256sum > SHA256SUMS
find . -maxdepth 1 -type f ! -name 'SHA*SUMS' -print0 | sort -z | xargs -0 sha512sum > SHA512SUMS
echo "=== SHA256SUMS ===" && cat SHA256SUMS
echo "=== SHA512SUMS ===" && cat SHA512SUMS
