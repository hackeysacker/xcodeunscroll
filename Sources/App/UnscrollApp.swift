import SwiftUI

@main
struct UnscrollApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var appState = AppState()
    @StateObject private var themeManager = ThemeManager.shared
    
    init() {
        // Initialize AppAudioManager with saved preferences
        let soundEnabled = UserDefaults.standard.object(forKey: "soundEnabled") as? Bool ?? true
        let hapticEnabled = UserDefaults.standard.object(forKey: "hapticEnabled") as? Bool ?? true
        
        // Note: AppAudioManager is a singleton, set defaults
        Task { @MainActor in
            AppAudioManager.shared.soundEnabled = soundEnabled
            AppAudioManager.shared.hapticEnabled = hapticEnabled
            AppAudioManager.shared.prepareHaptics()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(themeManager)
                .preferredColorScheme(.dark)
                .onAppear {
                    // Prepare haptics on first appear
                    Task { @MainActor in
                        AppAudioManager.shared.prepareHaptics()
                    }
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            // Handle scene phase changes if needed
        }
    }
}