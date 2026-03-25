import SwiftUI

struct DailyLoginRewardView: View {
    @EnvironmentObject var appState: AppState
    let streak: Int
    let gems: Int
    let onDismiss: () -> Void
    
    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0
    @State private var gemOffset: CGFloat = 50
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissReward()
                }
            
            VStack(spacing: 24) {
                // Title
                Text("DAILY LOGIN!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .yellow.opacity(0.5), radius: 10)
                
                // Streak badge
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.orange)
                    
                    Text("\(streak) Day\(streak == 1 ? "" : "s")")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color.orange.opacity(0.2))
                        .overlay(
                            Capsule()
                                .stroke(Color.orange.opacity(0.5), lineWidth: 2)
                        )
                )
                
                // Gems reward
                VStack(spacing: 8) {
                    Image(systemName: "diamond.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.cyan)
                        .shadow(color: .cyan.opacity(0.5), radius: 15)
                        .offset(y: gemOffset)
                        .onAppear {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.5).repeatForever(autoreverses: true)) {
                                gemOffset = -10
                            }
                        }
                    
                    Text("+\(gems)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.cyan, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .cyan.opacity(0.5), radius: 10)
                    
                    Text("GEMS")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.cyan.opacity(0.8))
                        .tracking(4)
                }
                
                // XP bonus
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("+25 XP")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.yellow)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.yellow.opacity(0.2))
                .cornerRadius(12)
                
                // Continue button
                Button(action: dismissReward) {
                    Text("AWESOME!")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                        .shadow(color: .purple.opacity(0.5), radius: 10)
                }
                .padding(.top, 10)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(hex: "1E293B"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    colors: [.cyan.opacity(0.5), .purple.opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
            )
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            // Trigger haptic
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            // Animate in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
    
    private func dismissReward() {
        withAnimation(.easeOut(duration: 0.2)) {
            scale = 0.8
            opacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            appState.showDailyLoginReward = false
            onDismiss()
        }
    }
}

#Preview {
    DailyLoginRewardView(streak: 3, gems: 20) {
        print("Dismissed")
    }
    .environmentObject(AppState())
}
