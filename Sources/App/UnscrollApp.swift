import SwiftUI

@main
struct UnscrollApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var appState = AppState()
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(themeManager)
                .preferredColorScheme(.dark)
                .onAppear {
                    // App initialization
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            // Handle scene phase changes if needed
        }
    }
}