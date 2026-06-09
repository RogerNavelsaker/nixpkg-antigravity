#!/usr/bin/env bash
set -euo pipefail

BASE_URL="https://antigravity-cli-auto-updater-974169037036.us-central1.run.app/manifests"

echo "Fetching manifests..."
linux_amd64=$(curl -fsSL "$BASE_URL/linux_amd64.json")
linux_arm64=$(curl -fsSL "$BASE_URL/linux_arm64.json")
darwin_amd64=$(curl -fsSL "$BASE_URL/darwin_amd64.json")
darwin_arm64=$(curl -fsSL "$BASE_URL/darwin_arm64.json")

VERSION=$(echo "$linux_amd64" | jq -r '.version')

jq -n \
  --arg version "$VERSION" \
  --argjson linux_amd64 "$linux_amd64" \
  --argjson linux_arm64 "$linux_arm64" \
  --argjson darwin_amd64 "$darwin_amd64" \
  --argjson darwin_arm64 "$darwin_arm64" \
  '{
    version: $version,
    sources: {
      "x86_64-linux": { url: $linux_amd64.url, sha512: $linux_amd64.sha512 },
      "aarch64-linux": { url: $linux_arm64.url, sha512: $linux_arm64.sha512 },
      "x86_64-darwin": { url: $darwin_amd64.url, sha512: $darwin_amd64.sha512 },
      "aarch64-darwin": { url: $darwin_arm64.url, sha512: $darwin_arm64.sha512 }
    }
  }' > sources.json

echo "Updated sources.json to version $VERSION"
