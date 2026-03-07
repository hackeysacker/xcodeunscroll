import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
    @State private var soundEnabled = UserDefaults.standard.object(forKey: "soundEnabled") as? Bool ?? true
    @State private var hapticEnabled = UserDefaults.standard.object(forKey: "hapticEnabled") as? Bool ?? true
    @State private var darkModeEnabled = UserDefaults.standard.object(forKey: "darkModeEnabled") as? Bool ?? true
    @State private var showDeleteAccountAlert = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(hex: "0A0F1C"), Color(hex: "0F172A")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Section
                    profileSection
                    
                    // App Settings
                    appSettingsSection
                    
                    // Account Section
                    accountSection
                    
                    // About Section
                    aboutSection
                }
                .padding(20)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Profile Section
    private var profileSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Profile")
                .font(.headline)
                .foregroundColor(.white.opacity(0.7))
            
            HStack(spacing: 16) {
                // Avatar
                Circle()
                    .fill(LinearGradient(
                        colors: [.purple, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text(String(appState.currentUser?.email?.prefix(1).uppercased() ?? "U"))
                            .font(.title2.bold())
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(appState.currentUser?.email ?? "Guest")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(appState.currentUser?.goal?.rawValue ?? "No goal set")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding(16)
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
        }
    }
    
    // MARK: - App Settings Section
    private var appSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("App Settings")
                .font(.headline)
                .foregroundColor(.white.opacity(0.7))
            
            VStack(spacing: 0) {
                SettingsToggleRow(
                    icon: "bell.fill",
                    iconColor: .red,
                    title: "Notifications",
                    subtitle: "Daily reminders & challenges",
                    isOn: $notificationsEnabled
                )
                .onChange(of: notificationsEnabled) { _, newValue in
                    UserDefaults.standard.set(newValue, forKey: "notificationsEnabled")
                }
                
                Divider().background(Color.white.opacity(0.1))
                
                SettingsToggleRow(
                    icon: "speaker.wave.2.fill",
                    iconColor: .blue,
                    title: "Sound Effects",
                    subtitle: "Challenge & UI sounds",
                    isOn: $soundEnabled
                )
                .onChange(of: soundEnabled) { _, newValue in
                    UserDefaults.standard.set(newValue, forKey: "soundEnabled")
                    AppAudioManager.shared.soundEnabled = newValue
                }
                
                Divider().background(Color.white.opacity(0.1))
                
                SettingsToggleRow(
                    icon: "iphone.radiowaves.left.and.right",
                    iconColor: .purple,
                    title: "Haptic Feedback",
                    subtitle: "Vibration on interactions",
                    isOn: $hapticEnabled
                )
                .onChange(of: hapticEnabled) { _, newValue in
                    UserDefaults.standard.set(newValue, forKey: "hapticEnabled")
                    AppAudioManager.shared.hapticEnabled = newValue
                }
                
                Divider().background(Color.white.opacity(0.1))
                
                SettingsToggleRow(
                    icon: "moon.fill",
                    iconColor: .indigo,
                    title: "Dark Mode",
                    subtitle: "Use dark theme",
                    isOn: $darkModeEnabled
                )
                .onChange(of: darkModeEnabled) { _, newValue in
                    UserDefaults.standard.set(newValue, forKey: "darkModeEnabled")
                    if newValue {
                        appState.colorScheme = .dark
                    } else {
                        appState.colorScheme = .light
                    }
                }
                
                Divider().background(Color.white.opacity(0.1))
                
                SettingsNavigationRow(
                    icon: "paintpalette.fill",
                    iconColor: .pink,
                    title: "Themes",
                    subtitle: "Customize app appearance"
                ) {
                    appState.showThemeSelection = true
                }
            }
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
        }
    }
    
    // MARK: - Account Section
    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Account")
                .font(.headline)
                .foregroundColor(.white.opacity(0.7))
            
            VStack(spacing: 0) {
                SettingsNavigationRow(
                    icon: "arrow.triangle.2.circlepath",
                    iconColor: .green,
                    title: "Sync Progress",
                    subtitle: appState.isOnline ? "Online - tap to sync" : "Offline - changes will sync when online"
                ) {
                    Task {
                        if let userId = appState.currentUser?.id {
                            await appState.syncToCloud(userId: userId)
                        }
                    }
                }
                
                Divider().background(Color.white.opacity(0.1))
                
                SettingsNavigationRow(
                    icon: "square.and.arrow.up",
                    iconColor: .orange,
                    title: "Export Data",
                    subtitle: "Download your progress"
                ) {
                    // Export functionality
                }
                
                Divider().background(Color.white.opacity(0.1))
                
                SettingsButtonRow(
                    icon: "rectangle.portrait.and.arrow.right",
                    iconColor: .red,
                    title: "Sign Out",
                    isDestructive: true
                ) {
                    Task {
                        await appState.signOut()
                    }
                }
            }
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
        }
    }
    
    // MARK: - About Section
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About")
                .font(.headline)
                .foregroundColor(.white.opacity(0.7))
            
            VStack(spacing: 0) {
                SettingsInfoRow(
                    icon: "info.circle.fill",
                    iconColor: .blue,
                    title: "Version",
                    value: "1.0.0"
                )
                
                Divider().background(Color.white.opacity(0.1))
                
                SettingsInfoRow(
                    icon: "star.fill",
                    iconColor: .yellow,
                    title: "Rate App",
                    value: ""
                )
                
                Divider().background(Color.white.opacity(0.1))
                
                SettingsInfoRow(
                    icon: "envelope.fill",
                    iconColor: .green,
                    title: "Contact Support",
                    value: ""
                )
            }
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
        }
    }
}

// MARK: - Settings Rows
struct SettingsToggleRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(iconColor)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.purple)
        }
        .padding(16)
    }
}

struct SettingsNavigationRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(16)
        }
    }
}

struct SettingsButtonRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let isDestructive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
                    .frame(width: 32)
                
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(isDestructive ? .red : .white)
                
                Spacer()
            }
            .padding(16)
        }
    }
}

struct SettingsInfoRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(iconColor)
                .frame(width: 32)
            
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.white)
            
            Spacer()
            
            if !value.isEmpty {
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(16)
    }
}
