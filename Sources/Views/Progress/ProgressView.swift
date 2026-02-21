import SwiftUI

struct ProgressView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ProgressPathView()
    }
}
