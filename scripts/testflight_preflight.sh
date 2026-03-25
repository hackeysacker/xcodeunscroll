#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "== Unscroll TestFlight Preflight =="

required_files=(
  "fastlane/Fastfile"
  "fastlane/Appfile"
  "fastlane/metadata/en-US/name.txt"
  "fastlane/metadata/en-US/subtitle.txt"
  "fastlane/metadata/en-US/description.txt"
  "fastlane/metadata/en-US/keywords.txt"
  "fastlane/metadata/en-US/release_notes.txt"
)

missing_files=()
for file in "${required_files[@]}"; do
  if [[ ! -f "$file" ]]; then
    missing_files+=("$file")
  fi
done

if [[ ${#missing_files[@]} -gt 0 ]]; then
  echo "Missing required release files:"
  printf " - %s\n" "${missing_files[@]}"
  exit 1
fi

required_env=(
  "APP_STORE_CONNECT_APPLE_ID"
  "APP_STORE_CONNECT_TEAM_ID"
  "APPLE_DEVELOPER_TEAM_ID"
)

missing_env=()
for key in "${required_env[@]}"; do
  if [[ -z "${!key:-}" ]]; then
    missing_env+=("$key")
  fi
done

if [[ ${#missing_env[@]} -gt 0 ]]; then
  echo "Missing required environment variables:"
  printf " - %s\n" "${missing_env[@]}"
  echo "Set them before running TestFlight upload lanes."
  exit 1
fi

if command -v bundle >/dev/null 2>&1 && [[ -f Gemfile ]]; then
  echo "Using Bundler to verify fastlane"
  bundle exec fastlane --version >/dev/null
elif command -v fastlane >/dev/null 2>&1; then
  echo "Using system fastlane"
  fastlane --version >/dev/null
else
  echo "fastlane is not installed. Install with: gem install fastlane"
  exit 1
fi

echo "Running build verification..."
xcodebuild \
  -project Unscroll.xcodeproj \
  -scheme Unscroll \
  -configuration Debug \
  -sdk iphonesimulator \
  CODE_SIGNING_ALLOWED=NO \
  build >/tmp/unscroll_preflight_build.log

echo "Preflight passed."
echo "Next: fastlane ios beta"
