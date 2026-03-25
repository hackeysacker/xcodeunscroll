import SwiftUI

// MARK: - Duolingo-Style Winding Progress Path
struct WindingProgressPath: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedLevel: Int?
    @State private var showChallenge: Bool = false
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "0A0F1C"), Color(hex: "1E293B")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    Text("Progress Path")
                        .foregroundColor(.white)
                        .font(.title)
                    
                    Text("Level \(appState.progress?.level ?? 1)")
                        .foregroundColor(.white)
                        .font(.headline)
                }
                .padding()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    WindingProgressPath().environmentObject(AppState())
}
