import SwiftUI
import os.log



struct LevelUpCelebrationView: View {
    private static let logger = Logger(subsystem: "com.unscroll.focusflow", category: "LevelUpCelebrationView")
    @EnvironmentObject var appState: AppState
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var gemOffset: CGFloat = 50
    @State private var rotation: Double = 0
    @State private var sparkleRotation: Double = 0
    
    let newLevel: Int
    let gemsEarned: Int
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .opacity(opacity)
            
            // Main card
            VStack(spacing: 24) {
                // Level up icon with glow
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.yellow.opacity(0.6), .orange.opacity(0.3), .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .scaleEffect(scale)
                    
                    // Main circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: .yellow.opacity(0.8), radius: 20)
                    
                    Image(systemName: "star.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                        .shadow(color: .white.opacity(0.5), radius: 5)
                }
                .scaleEffect(scale)
                .rotationEffect(.degrees(rotation))
                
                // Text
                VStack(spacing: 8) {
                    Text("LEVEL UP!")
                        .font(.system(size: 32, weight: .black))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange, .red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .orange.opacity(0.5), radius: 2)
                    
                    Text("Level \(newLevel)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                }
                .opacity(opacity)
                
                // Rewards
                HStack(spacing: 20) {
                    RewardBadge(icon: "gem.fill", value: "+\(gemsEarned)", color: .green)
                }
                .opacity(opacity)
                
                // Continue button
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        appState.showLevelUpCelebration = false
                    }
                    onDismiss()
                }) {
                    Text("AWESOME!")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 200, height: 50)
                        .background(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                        .shadow(color: .yellow.opacity(0.5), radius: 10)
                }
                .opacity(opacity)
            }
            .padding(32)
        }
        .onAppear {
            // Haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            // Animate in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
            
            // Continuous rotation animation
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            
            // Sparkle rotation
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: true)) {
                sparkleRotation = 15
            }
        }
    }
}

struct RewardBadge: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 20))
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(color.opacity(0.2))
        .cornerRadius(20)
    }
}

#Preview {
    LevelUpCelebrationView(newLevel: 5, gemsEarned: 10) {
        // Dismissed
    }
    .environmentObject(AppState())
}
