import SwiftUI

@main
struct FocusFlowApp: App {
    @StateObject private var appState = AppState()
    
    init() {
        // Load saved settings into AudioManager
        let soundEnabled = UserDefaults.standard.object(forKey: "soundEnabled") as? Bool ?? true
        let hapticEnabled = UserDefaults.standard.object(forKey: "hapticEnabled") as? Bool ?? true
        AppAudioManager.shared.soundEnabled = soundEnabled
        AppAudioManager.shared.hapticEnabled = hapticEnabled
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .preferredColorScheme(appState.colorScheme)
        }
    }
}
