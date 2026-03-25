import SwiftUI

@main
struct UnscrollApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var appState = AppState()
    @StateObject private var themeService = ThemeService.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(themeService)
                .preferredColorScheme(themeService.appearance.preferredColorScheme)
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
