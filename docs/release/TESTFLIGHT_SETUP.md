# TestFlight Setup

1. Open Xcode > Settings > Accounts and sign into your Apple Developer account.
2. In App Store Connect, create app `Unscroll` with bundle id `com.unscroll.app`.
3. In Xcode, set `DEVELOPMENT_TEAM` in project build settings.
4. Run `scripts/testflight_preflight.sh`.
5. Run `scripts/bump_version.sh <version> <build>` before each upload.
6. Run automated upload with `fastlane ios beta` (preferred), or archive manually in Xcode.
7. Confirm build appears in App Store Connect.
8. In App Store Connect > TestFlight:
   - Add internal testers
   - Fill compliance notes and testing notes
   - Submit build for beta review (if external testing)
9. Track feedback and crashes from TestFlight dashboard.

See `docs/release/FASTLANE_RELEASE.md` for lane setup and environment variables.

## Exit Criteria
- Latest build processed by App Store Connect
- At least one internal tester installed and launched the build
- Known issues documented in release notes
