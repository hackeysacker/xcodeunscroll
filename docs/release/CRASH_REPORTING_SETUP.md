# Crash Reporting Setup (Firebase Crashlytics)

The app includes a `CrashReportingService` with optional Crashlytics hooks via `#if canImport(FirebaseCrashlytics)`.

## To enable Crashlytics
1. Add Firebase SDK (Crashlytics + Analytics) to the project.
2. Add `GoogleService-Info.plist` to the app target.
3. Initialize Firebase in app launch.
4. Verify symbols upload in CI/release builds.

## Validation
- Trigger non-fatal test log and confirm it appears in Crashlytics dashboard.
- Trigger test crash on debug build and confirm crash appears after relaunch.
