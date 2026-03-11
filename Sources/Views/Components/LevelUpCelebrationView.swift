// Unscroll - Level Up Celebration View
// Shows celebration animation when user levels up

import SwiftUI

struct LevelUpCelebrationView: View {
    let newLevel: Int
    let xpReward: Int
    let gemReward: Int
    let onDismiss: () -> Void
    
    @State private var showContent = false
    @State private var scale: CGFloat = 0.5
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            // Background blur
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            // Celebration content
            VStack(spacing: 24) {
                // Star burst animation
                ZStack {
                    ForEach(0..<8, id: \.self) { index in
                        Circle()
                            .fill(
                                AngularGradient(
                                    gradient: Gradient(colors: [.yellow, .orange, .pink]),
                                    center: .center
                                )
                            )
                            .frame(width: 20, height: 20)
                            .offset(y: -80)
                            .rotationEffect(.degrees(Double(index) * 45))
                            .opacity(showContent ? 1 : 0)
                            .animation(
                                .easeOut(duration: 0.8).delay(Double(index) * 0.1),
                                value: showContent
                            )
                    }
                    
                    // Main star icon
                    Image(systemName: "star.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .rotationEffect(.degrees(rotation))
                        .scaleEffect(scale)
                }
                
                // Level up text
                VStack(spacing: 8) {
                    Text("LEVEL UP!")
                        .font(.system(size: 36, weight: .black))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .orange.opacity(0.5), radius: 10, x: 0, y: 5)
                    
                    Text("Level \(newLevel)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.3), value: showContent)
                
                // Rewards
                HStack(spacing: 32) {
                    // XP Reward
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .foregroundColor(.yellow)
                        Text("+\(xpReward) XP")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(20)
                    
                    // Gem Reward
                    HStack(spacing: 8) {
                        Image(systemName: "gem.fill")
                            .foregroundColor(.cyan)
                        Text("+\(gemReward)")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(20)
                }
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.5).delay(0.5), value: showContent)
                
                // Continue button
                Button(action: onDismiss) {
                    Text("AWESOME!")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 200, height: 56)
                        .background(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(28)
                        .shadow(color: .orange.opacity(0.5), radius: 10, x: 0, y: 5)
                }
                .padding(.top, 16)
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.5).delay(0.7), value: showContent)
            }
            .padding(32)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                scale = 1.0
            }
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                showContent = true
            }
        }
    }
}

// Preview
#Preview {
    LevelUpCelebrationView(
        newLevel: 5,
        xpReward: 100,
        gemReward: 25,
        onDismiss: {}
    )
}
