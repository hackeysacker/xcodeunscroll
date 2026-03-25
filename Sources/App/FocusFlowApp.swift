import SwiftUI
import BackgroundTasks
import FirebaseCore

@main
struct FocusFlowApp: App {
    @StateObject private var appState = AppState()
    
    init() {
        // Load saved settings into AudioManager
        let soundEnabled = UserDefaults.standard.object(forKey: "soundEnabled") as? Bool ?? true
        let hapticEnabled = UserDefaults.standard.object(forKey: "hapticEnabled") as? Bool ?? true
        AppAudioManager.shared.soundEnabled = soundEnabled
        AppAudioManager.shared.hapticEnabled = hapticEnabled
        
        // Register background tasks for battery-efficient background refresh
        BackgroundTaskManager.shared.registerBackgroundTasks()
        
        // Initialize Firebase (crash reporting & analytics)
        // Note: Requires GoogleService-Info.plist in Sources/App/ directory
        // Download from Firebase Console → Project Settings → Your apps
        #if !DEBUG
        if FirebaseApp.app() == nil {
            // Attempt to configure - will fail gracefully if plist missing
            if let _ = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
                FirebaseApp.configure()
            }
        }
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .preferredColorScheme(appState.colorScheme)
        }
    }
}
