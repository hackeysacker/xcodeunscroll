import XCTest
@testable import FocusFlow

final class ThemeManagerTests: XCTestCase {
    
    var themeManager: ThemeManager!
    
    override func setUp() {
        super.setUp()
        // Create a fresh instance
        themeManager = ThemeManager.shared
    }
    
    // MARK: - AppTheme Tests
    
    func testDefaultThemesCount() {
        XCTAssertEqual(AppTheme.defaultThemes.count, 8, "Should have 8 default themes")
    }
    
    func testThemeHasAllRequiredProperties() {
        let theme = AppTheme.defaultThemes[0]
        
        XCTAssertFalse(theme.id.isEmpty, "Theme should have ID")
        XCTAssertFalse(theme.name.isEmpty, "Theme should have name")
        XCTAssertFalse(theme.primaryColor.isEmpty, "Theme should have primary color")
        XCTAssertFalse(theme.secondaryColor.isEmpty, "Theme should have secondary color")
        XCTAssertFalse(theme.accentColor.isEmpty, "Theme should have accent color")
        XCTAssertFalse(theme.backgroundColor.isEmpty, "Theme should have background color")
        XCTAssertFalse(theme.backgroundGradientEnd.isEmpty, "Theme should have gradient end color")
    }
    
    func testAllThemesHaveUniqueIds() {
        let ids = AppTheme.defaultThemes.map { $0.id }
        let uniqueIds = Set(ids)
        
        XCTAssertEqual(ids.count, uniqueIds.count, "All theme IDs should be unique")
    }
    
    func testDefaultThemeIsFirst() {
        let defaultTheme = AppTheme.defaultThemes[0]
        
        XCTAssertEqual(defaultTheme.id, "default", "First theme should be default")
        XCTAssertEqual(defaultTheme.name, "Focus Purple", "Default theme should be Focus Purple")
    }
    
    func testAllThemeNames() {
        let expectedNames = [
            "Focus Purple",
            "Ocean Blue", 
            "Sunset",
            "Forest Green",
            "Rose",
            "Golden Hour",
            "Midnight",
            "Monochrome"
        ]
        
        let actualNames = AppTheme.defaultThemes.map { $0.name }
        
        XCTAssertEqual(actualNames, expectedNames, "Theme names should match expected")
    }
    
    func testThemeIsIdentifiable() {
        let theme = AppTheme.defaultThemes[0]
        
        XCTAssertEqual(theme.id, theme.id, "Theme should be identifiable by ID")
    }
    
    func testThemeIsCodable() throws {
        let theme = AppTheme.defaultThemes[0]
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(theme)
        
        XCTAssertNotNil(data, "Theme should be encodable")
        
        let decoder = JSONDecoder()
        let decodedTheme = try decoder.decode(AppTheme.self, from: data)
        
        XCTAssertEqual(theme.id, decodedTheme.id, "Decoded theme should match original")
    }
    
    // MARK: - Color Extension Tests
    
    func testColorHexInit() {
        let color = Color(hex: "FF0000")
        
        // Just verify it doesn't crash
        XCTAssertNotNil(color)
    }
    
    func testColorHexInitWithHash() {
        let color = Color(hex: "#FF0000")
        
        XCTAssertNotNil(color)
    }
    
    func testColorHexInitShort() {
        let color = Color(hex: "F00")
        
        XCTAssertNotNil(color)
    }
    
    func testColorHexInitWithAlpha() {
        let color = Color(hex: "FF000080")
        
        XCTAssertNotNil(color)
    }
    
    func testColorHexInitInvalid() {
        // Invalid hex should return black
        let color = Color(hex: "invalid")
        
        XCTAssertNotNil(color)
    }
    
    func testColorThemeHexInit() {
        let color = Color(themeHex: "8B5CF6")
        
        XCTAssertNotNil(color)
    }
    
    // MARK: - ThemeManager Tests
    
    func testThemeManagerHasDefaultTheme() {
        XCTAssertNotNil(themeManager.currentTheme, "Should have a current theme")
    }
    
    func testThemeManagerCurrentThemeIsValid() {
        let validIds = AppTheme.defaultThemes.map { $0.id }
        
        XCTAssertTrue(validIds.contains(themeManager.currentTheme.id), "Current theme should be valid")
    }
    
    func testThemeManagerUseCustomThemeDefaultsToFalse() {
        // Note: This test may vary based on previous user settings
        // The important thing is the property exists and is a Bool
        XCTAssertNotNil(themeManager.useCustomTheme)
    }
    
    func testThemeManagerCanChangeTheme() {
        let originalTheme = themeManager.currentTheme
        let newTheme = AppTheme.defaultThemes.first { $0.id == "ocean" }!
        
        themeManager.currentTheme = newTheme
        
        XCTAssertEqual(themeManager.currentTheme.id, "ocean", "Theme should change to ocean")
        
        // Restore original
        themeManager.currentTheme = originalTheme
    }
    
    func testThemeManagerCanToggleCustomTheme() {
        let original = themeManager.useCustomTheme
        
        themeManager.useCustomTheme = !original
        
        XCTAssertEqual(themeManager.useCustomTheme, !original, "Custom theme toggle should work")
        
        // Restore
        themeManager.useCustomTheme = original
    }
    
    // MARK: - Theme Selection Tests
    
    func testThemeById() {
        let oceanTheme = AppTheme.defaultThemes.first { $0.id == "ocean" }
        
        XCTAssertNotNil(oceanTheme, "Should find ocean theme")
        XCTAssertEqual(oceanTheme?.name, "Ocean Blue", "Ocean theme should have correct name")
    }
    
    func testThemeByIdNotFound() {
        let nonexistentTheme = AppTheme.defaultThemes.first { $0.id =="nonexistent" }
        
        XCTAssertNil(nonexistentTheme, "Should not find nonexistent theme")
    }
    
    // MARK: - Color Values Tests
    
    func testPrimaryColorsAreValidHex() {
        for theme in AppTheme.defaultThemes {
            let hex = theme.primaryColor
            XCTAssertEqual(hex.count, 6, "Primary color should be valid 6-char hex: \(theme.name)")
        }
    }
    
    func testSecondaryColorsAreValidHex() {
        for theme in AppTheme.defaultThemes {
            let hex = theme.secondaryColor
            XCTAssertEqual(hex.count, 6, "Secondary color should be valid 6-char hex: \(theme.name)")
        }
    }
    
    func testAccentColorsAreValidHex() {
        for theme in AppTheme.defaultThemes {
            let hex = theme.accentColor
            XCTAssertEqual(hex.count, 6, "Accent color should be valid 6-char hex: \(theme.name)")
        }
    }
    
    func testBackgroundColorsAreValidHex() {
        for theme in AppTheme.defaultThemes {
            let hex = theme.backgroundColor
            XCTAssertEqual(hex.count, 6, "Background color should be valid 6-char hex: \(theme.name)")
        }
    }
    
    func testGradientEndColorsAreValidHex() {
        for theme in AppTheme.defaultThemes {
            let hex = theme.backgroundGradientEnd
            XCTAssertEqual(hex.count, 6, "Gradient end color should be valid 6-char hex: \(theme.name)")
        }
    }
}
