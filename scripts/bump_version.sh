#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <marketing_version> <build_number>"
  echo "Example: $0 1.1.0 12"
  exit 1
fi

MARKETING_VERSION="$1"
BUILD_NUMBER="$2"

if [[ ! "$MARKETING_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Marketing version must match X.Y.Z"
  exit 1
fi

if [[ ! "$BUILD_NUMBER" =~ ^[0-9]+$ ]]; then
  echo "Build number must be numeric"
  exit 1
fi

PROJECT_YML="project.yml"
PBXPROJ="Unscroll.xcodeproj/project.pbxproj"

awk -v mv="$MARKETING_VERSION" -v bn="$BUILD_NUMBER" '
  { gsub(/MARKETING_VERSION: "[^"]+"/, "MARKETING_VERSION: \"" mv "\"") }
  { gsub(/CURRENT_PROJECT_VERSION: "[^"]+"/, "CURRENT_PROJECT_VERSION: \"" bn "\"") }
  { print }
' "$PROJECT_YML" > "$PROJECT_YML.tmp" && mv "$PROJECT_YML.tmp" "$PROJECT_YML"

awk -v mv="$MARKETING_VERSION" -v bn="$BUILD_NUMBER" '
  { gsub(/MARKETING_VERSION = [^;]+;/, "MARKETING_VERSION = " mv ";") }
  { gsub(/CURRENT_PROJECT_VERSION = [^;]+;/, "CURRENT_PROJECT_VERSION = " bn ";") }
  { print }
' "$PBXPROJ" > "$PBXPROJ.tmp" && mv "$PBXPROJ.tmp" "$PBXPROJ"

echo "Updated version to $MARKETING_VERSION ($BUILD_NUMBER)"
