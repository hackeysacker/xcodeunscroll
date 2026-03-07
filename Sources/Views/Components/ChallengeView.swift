import SwiftUI

struct ChallengeView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    let challenge: AllChallengeType
    
    var body: some View {
        UniversalChallengeView(challenge: challenge)
            .environmentObject(appState)
    }
}
