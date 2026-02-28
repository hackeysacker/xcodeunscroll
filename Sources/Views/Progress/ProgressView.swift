import SwiftUI

struct ProgressView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "0A0F1C"), Color(hex: "1E293B")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "map.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.purple)
                
                Text("Progress Path")
                    .font(.title)
                    .foregroundColor(.white)
                
                Text("Level \(appState.progress?.level ?? 1)")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Text("\(appState.progress?.totalXP ?? 0) XP")
                    .font(.subheadline)
                    .foregroundColor(.yellow)
            }
        }
    }
}

#Preview {
    ProgressView()
        .environmentObject(AppState())
}
