import SwiftUI

@main
struct UnscrollApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var appState = AppState()
    @StateObject private var themeManager = ThemeManager.shared
    
    init() {
        // BGTaskScheduler requires handlers to be registered before the app finishes
        // launching, otherwise every later submit() fails.
        BackgroundTaskManager.shared.registerBackgroundTasks()

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
                        appState.refreshHearts()
                    }
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            // Credit hearts that regenerated while the app was backgrounded.
            Task { @MainActor in
                appState.refreshHearts()
            }
        }
    }
}