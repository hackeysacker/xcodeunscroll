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
                .preferredColorScheme(themeManager.appearance.preferredColorScheme)
                .onAppear {
                    BackgroundSyncService.shared.register()
                    BackgroundSyncService.shared.syncHandler = {
                        await appState.performBackgroundSync()
                    }
                    BackgroundSyncService.shared.scheduleNextSync()

                    Task {
                        await PurchaseService.shared.loadProductsIfNeeded()
                    }
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                BackgroundSyncService.shared.scheduleNextSync()
            }
        }
    }
}
