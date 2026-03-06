import SwiftUI

// MARK: - App Theme Model
struct AppTheme: Identifiable, Codable {
    let id: String
    let name: String
    let primaryColor: String
    let secondaryColor: String
    let accentColor: String
    let backgroundColor: String
    let backgroundGradientEnd: String
    
    static let defaultThemes: [AppTheme] = [
        AppTheme(
            id: "default",
            name: "Focus Purple",
            primaryColor: "8B5CF6",
            secondaryColor: "6366F1",
            accentColor: "A855F7",
            backgroundColor: "0A0F1C",
            backgroundGradientEnd: "1E293B"
        ),
        AppTheme(
            id: "ocean",
            name: "Ocean Blue",
            primaryColor: "0EA5E9",
            secondaryColor: "0284C7",
            accentColor: "38BDF8",
            backgroundColor: "0C1929",
            backgroundGradientEnd: "1E3A5F"
        ),
        AppTheme(
            id: "sunset",
            name: "Sunset",
            primaryColor: "F97316",
            secondaryColor: "EA580C",
            accentColor: "FB923C",
            backgroundColor: "1A0A05",
            backgroundGradientEnd: "3D1A0A"
        ),
        AppTheme(
            id: "forest",
            name: "Forest Green",
            primaryColor: "22C55E",
            secondaryColor: "16A34A",
            accentColor: "4ADE80",
            backgroundColor: "0A1A0C",
            backgroundGradientEnd: "1A2E1A"
        ),
        AppTheme(
            id: "rose",
            name: "Rose",
            primaryColor: "F43F5E",
            secondaryColor: "E11D48",
            accentColor: "FB7185",
            backgroundColor: "1A0A10",
            backgroundGradientEnd: "2E1A1F"
        ),
        AppTheme(
            id: "gold",
            name: "Golden Hour",
            primaryColor: "EAB308",
            secondaryColor: "CA8A04",
            accentColor: "FACC15",
            backgroundColor: "1A1405",
            backgroundGradientEnd: "2E2208"
        ),
        AppTheme(
            id: "midnight",
            name: "Midnight",
            primaryColor: "6366F1",
            secondaryColor: "4F46E5",
            accentColor: "818CF8",
            backgroundColor: "050510",
            backgroundGradientEnd: "101025"
        ),
        AppTheme(
            id: "monochrome",
            name: "Monochrome",
            primaryColor: "A1A1AA",
            secondaryColor: "71717A",
            accentColor: "D4D4D8",
            backgroundColor: "0A0A0A",
            backgroundGradientEnd: "18181B"
        )
    ]
}

// MARK: - Theme Manager
@MainActor
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: AppTheme {
        didSet {
            saveTheme()
        }
    }
    
    @Published var useCustomTheme: Bool {
        didSet {
            UserDefaults.standard.set(useCustomTheme, forKey: "useCustomTheme")
        }
    }
    
    private init() {
        // Load saved theme
        if let themeId = UserDefaults.standard.string(forKey: "selectedThemeId"),
           let theme = AppTheme.defaultThemes.first(where: { $0.id == themeId }) {
            self.currentTheme = theme
        } else {
            self.currentTheme = AppTheme.defaultThemes[0]
        }
        self.useCustomTheme = UserDefaults.standard.bool(forKey: "useCustomTheme")
    }
    
    private func saveTheme() {
        UserDefaults.standard.set(currentTheme.id, forKey: "selectedThemeId")
    }
}

// MARK: - Theme Colors Extension
extension Color {
    init(themeHex: String) {
        let hex = themeHex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Theme-aware Background
struct ThemeBackground: View {
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        LinearGradient(
            colors: [
                Color(themeHex: themeManager.currentTheme.backgroundColor),
                Color(themeHex: themeManager.currentTheme.backgroundGradientEnd)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

// MARK: - Theme Button
struct ThemeButton: View {
    let theme: AppTheme
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Preview circle
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color(themeHex: theme.primaryColor), Color(themeHex: theme.secondaryColor)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 44, height: 44)
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                Text(theme.name)
                    .font(.system(size: 11))
                    .foregroundColor(isSelected ? .white : .gray)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.white.opacity(0.1) : Color.clear)
            .cornerRadius(12)
        }
    }
}

// MARK: - Preview
#Preview {
    VStack {
        ForEach(AppTheme.defaultThemes) { theme in
            HStack {
                Circle()
                    .fill(Color(themeHex: theme.primaryColor))
                    .frame(width: 30, height: 30)
                Text(theme.name)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
        }
    }
    .background(Color(themeHex: "0A0F1C"))
}
