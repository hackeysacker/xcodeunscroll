import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    // Performance: Track animation state to prevent unnecessary redraws
    @State private var previousOnboardingState: Bool?
    
    var body: some View {
        ZStack {
            // Background gradient - using static gradient for performance
            Color(hex: "0A0F1C")
                .ignoresSafeArea()
            
            if appState.isLoading {
                SplashScreen()
            } else if !appState.isOnboarded {
                OnboardingFlowView()
            } else {
                VStack(spacing: 0) {
                    // Universal Header
                    UniversalHeader()
                        .environmentObject(appState)
                    
                    // Tab Content
                    MainTabView()
                }
            }
        }
        // Optimized animation - only animate on state change
        .animation(.easeInOut(duration: 0.25), value: appState.isOnboarded)
        .animation(.easeInOut(duration: 0.2), value: appState.isLoading)
        .fullScreenCover(isPresented: $appState.showLevelUpCelebration) {
            LevelUpCelebrationView(
                newLevel: appState.progress?.level ?? 1,
                gemsEarned: 10
            ) {
                // Dismiss action if needed
            }
            .environmentObject(appState)
        }
        .fullScreenCover(isPresented: $appState.showDailyLoginReward) {
            DailyLoginRewardView(
                streak: appState.dailyLoginStreak,
                gems: appState.dailyLoginGems
            ) {
                // Dismiss action if needed
            }
            .environmentObject(appState)
        }
    }
}

// MARK: - Universal Header
struct UniversalHeader: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack(spacing: 16) {
            // Hearts
            HStack(spacing: 6) {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .font(.system(size: 14))
                Text("\(appState.progress?.hearts ?? 5)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.red.opacity(0.15))
            .cornerRadius(16)
            
            Spacer()
            
            // Streak
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 14))
                Text("\(appState.progress?.streakDays ?? 0)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.orange.opacity(0.15))
            .cornerRadius(16)
            
            // XP
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 14))
                Text("\(appState.progress?.totalXP ?? 0)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.yellow.opacity(0.15))
            .cornerRadius(16)
            
            // Gems
            HStack(spacing: 6) {
                Image(systemName: "diamond.fill")
                    .foregroundColor(.cyan)
                    .font(.system(size: 14))
                Text("\(appState.progress?.gems ?? 0)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.cyan.opacity(0.15))
            .cornerRadius(16)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 6)
        .background(Color(hex: "0A0F1C"))
    }
}

// MARK: - Splash Screen
struct SplashScreen: View {
    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0
    
    var body: some View {
        VStack(spacing: 24) {
            // Logo - using static gradient for performance
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.purple, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 140, height: 140)
                
                Circle()
                    .stroke(Color.purple.opacity(0.5), lineWidth: 2)
                    .frame(width: 180, height: 180)
                
                Image(systemName: "xmark")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.red)
            }
            .scaleEffect(scale)
            .opacity(opacity)
            
            Text("FocusFlow")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .opacity(opacity)
        }
        .onAppear {
            // Optimized spring animation for smoother feel
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).speed(1.2)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 0) {
            // Content - using page style for smooth transitions
            TabView(selection: $appState.selectedTab) {
                HomeView()
                    .tag(AppState.Tab.home)
                
                ProgressView()
                    .tag(AppState.Tab.progress)
                
                ScreenTimeDashboardView()
                    .tag(AppState.Tab.screenTime)
                
                PracticeView()
                    .tag(AppState.Tab.practice)
                
                ProfileView()
                    .tag(AppState.Tab.profile)
                
                SettingsView()
                    .tag(AppState.Tab.settings)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.15), value: appState.selectedTab)
            
            // Bottom Navigation
            HStack(spacing: 0) {
                ForEach(AppState.Tab.allCases, id: \.self) { tab in
                    GlassTabButton(
                        tab: tab,
                        isActive: appState.selectedTab == tab
                    ) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            appState.selectedTab = tab
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea(edges: .bottom)
            )
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
