import SwiftUI

struct ThemeSelectionView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @StateObject private var themeManager = ThemeManager.shared
    @State private var useCustomTheme: Bool = ThemeManager.shared.useCustomTheme
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color(themeHex: themeManager.currentTheme.backgroundColor),
                        Color(themeHex: themeManager.currentTheme.backgroundGradientEnd)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Preview Card
                        previewCard
                        
                        // Theme Toggle
                        themeToggleSection
                        
                        // Theme Grid
                        if useCustomTheme {
                            themeGridSection
                        }
                        
                        // Premium notice
                        if appState.currentUser?.isPremium != true {
                            premiumNotice
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Themes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.gray)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(themeHex: themeManager.currentTheme.primaryColor))
                    .fontWeight(.bold)
                }
            }
        }
    }
    
    // MARK: - Preview Card
    var previewCard: some View {
        VStack(spacing: 16) {
            // App icon preview
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [
                            Color(themeHex: themeManager.currentTheme.primaryColor),
                            Color(themeHex: themeManager.currentTheme.secondaryColor)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
            }
            
            Text(themeManager.currentTheme.name)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            // Mini UI preview
            HStack(spacing: 12) {
                // Hearts
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill").foregroundColor(.red)
                    Text("5").foregroundColor(.white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.red.opacity(0.2))
                .cornerRadius(10)
                
                // Streak
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill").foregroundColor(.orange)
                    Text("7").foregroundColor(.white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.orange.opacity(0.2))
                .cornerRadius(10)
                
                // Gems
                HStack(spacing: 4) {
                    Image(systemName: "diamond.fill").foregroundColor(Color(themeHex: themeManager.currentTheme.accentColor))
                    Text("100").foregroundColor(.white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(themeHex: themeManager.currentTheme.accentColor).opacity(0.2))
                .cornerRadius(10)
            }
        }
        .padding(24)
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
    }
    
    // MARK: - Theme Toggle
    var themeToggleSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Custom Theme")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("Choose your app color scheme")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Toggle("", isOn: $useCustomTheme)
                .tint(Color(themeHex: themeManager.currentTheme.primaryColor))
                .onChange(of: useCustomTheme) { _, newValue in
                    themeManager.useCustomTheme = newValue
                }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
    
    // MARK: - Theme Grid
    var themeGridSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Available Themes")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(AppTheme.defaultThemes) { theme in
                    ThemeButton(
                        theme: theme,
                        isSelected: themeManager.currentTheme.id == theme.id
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            themeManager.currentTheme = theme
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Premium Notice
    var premiumNotice: some View {
        HStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.system(size: 20))
                .foregroundColor(.yellow)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Premium Feature")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("Custom themes are free during beta!")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [Color.yellow.opacity(0.2), Color.orange.opacity(0.1)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(16)
    }
}

#Preview {
    ThemeSelectionView()
        .environmentObject(AppState())
}
