# Fastlane Release Automation

## Prerequisites
- Ruby + `fastlane` installed (`gem install fastlane` or via Bundler)
- Apple account with App Store Connect access
- App created in App Store Connect (`com.unscroll.app`)

## Required Environment Variables
- `APP_STORE_CONNECT_APPLE_ID`
- `APP_STORE_CONNECT_TEAM_ID`
- `APPLE_DEVELOPER_TEAM_ID`
- `FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD` (for upload in some setups)

## Lanes
- `fastlane ios verify`
  - Builds simulator Debug app for quick verification
- `fastlane ios beta`
  - Builds archive and uploads to TestFlight
- `fastlane ios metadata`
  - Uploads metadata only from `fastlane/metadata`

## Preflight Script
- `scripts/testflight_preflight.sh`
  - Validates release files, required environment variables, fastlane availability, and simulator build health before upload.

## First-Time Setup
1. Update metadata text files under `fastlane/metadata/en-US`.
2. Run `scripts/testflight_preflight.sh`.
3. Run `scripts/bump_version.sh <version> <build>`.
4. Run `fastlane ios beta`.
5. In App Store Connect, complete compliance/testing notes and add testers.
