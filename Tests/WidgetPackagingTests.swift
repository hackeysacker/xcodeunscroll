import XCTest

/// Regression tests for the widget extension packaging bug fixed on Oct 28, 2026.
///
/// The `FocusFlowWidgetExtension` target had a misspelled `GENERATE_INFPLIST_FILE`
/// build setting, which caused it to inherit the *app's* Info.plist. The resulting
/// `.appex` had no `NSExtension` dictionary, so iOS refused to install it:
/// `extensionDictionary must be set in placeholder attributes`.
///
/// The app itself still compiled fine, so this was invisible to every "BUILD SUCCEEDED"
/// check — it only surfaced when `xcodebuild test` failed at the install step.
///
/// These tests assert the packaged extension is actually installable-shaped.
final class WidgetPackagingTests: XCTestCase {

    /// Locates the built `FocusFlowWidgetExtension.appex` inside the host app bundle.
    private func builtExtensionBundle() -> Bundle? {
        // When running under the app host, the extension lives in PlugIns/.
        if let plugins = Bundle.main.builtInPlugInsURL {
            let appex = plugins.appendingPathComponent("FocusFlowWidgetExtension.appex")
            if FileManager.default.fileExists(atPath: appex.path) {
                return Bundle(url: appex)
            }
        }
        return nil
    }

    func testWidgetExtensionIsPresentInAppBundle() throws {
        let bundle = try XCTUnwrap(
            builtExtensionBundle(),
            "FocusFlowWidgetExtension.appex not found in the host app bundle. "
            + "The widget target is not embedded — the app cannot install on device."
        )
        XCTAssertEqual(bundle.bundleIdentifier, "com.focusflow.app.widget")
    }

    func testWidgetExtensionInfoPlistHasNSExtensionDictionary() throws {
        let bundle = try XCTUnwrap(builtExtensionBundle())

        let info = try XCTUnwrap(
            bundle.infoDictionary,
            "The built widget extension has no Info.plist."
        )
        let extensionDict = try XCTUnwrap(
            info["NSExtension"] as? [String: Any],
            "The built widget extension Info.plist has no NSExtension dictionary. "
            + "iOS will refuse to install the app: "
            + "'extensionDictionary must be set in placeholder attributes'."
        )

        let identifier = try XCTUnwrap(
            extensionDict["NSExtensionPointIdentifier"] as? String,
            "NSExtension is missing NSExtensionPointIdentifier."
        )
        XCTAssertEqual(identifier, "com.apple.widgetkit-extension")
    }

    func testWidgetExtensionHasNoPrincipalClassRegression() throws {
        let bundle = try XCTUnwrap(builtExtensionBundle())
        let info = try XCTUnwrap(bundle.infoDictionary)
        let extensionDict = try XCTUnwrap(info["NSExtension"] as? [String: Any])

        // WidgetKit extensions must NOT declare NSExtensionPrincipalClass —
        // the @main WidgetBundle is the entry point. A leftover principal class
        // would cause a launch failure at runtime.
        XCTAssertNil(
            extensionDict["NSExtensionPrincipalClass"],
            "NSExtensionPrincipalClass should be absent for a WidgetKit extension."
        )
    }
}
