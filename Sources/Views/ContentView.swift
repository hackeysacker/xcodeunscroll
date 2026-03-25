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
        // Drawing group for smoother compositing performance
        .drawingGroup()
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
        .sheet(isPresented: $appState.showThemeSelection) {
            ThemeSelectionView()
                .environmentObject(appState)
        }
    }
}

// MARK: - Universal Header
struct UniversalHeader: View {
    @EnvironmentObject var appState: AppState
    
    // Cache values to avoid recalculating on every redraw
    @State private var cachedHearts: Int = 5
    @State private var cachedStreak: Int = 0
    @State private var cachedXP: Int = 0
    @State private var cachedGems: Int = 0
    
    // Animation states for value changes
    @State private var heartsScale: CGFloat = 1.0
    @State private var streakScale: CGFloat = 1.0
    @State private var xpScale: CGFloat = 1.0
    @State private var gemsScale: CGFloat = 1.0
    
    var body: some View {
        HStack(spacing: 16) {
            // Hearts
            HStack(spacing: 6) {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .font(.system(size: 14))
                Text("\(cachedHearts)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.red.opacity(0.15))
            .cornerRadius(16)
            .scaleEffect(heartsScale)
            
            Spacer()
            
            // Streak
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 14))
                Text("\(cachedStreak)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.orange.opacity(0.15))
            .cornerRadius(16)
            .scaleEffect(streakScale)
            
            // XP
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 14))
                Text("\(cachedXP)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.yellow.opacity(0.15))
            .cornerRadius(16)
            .scaleEffect(xpScale)
            
            // Gems
            HStack(spacing: 6) {
                Image(systemName: "diamond.fill")
                    .foregroundColor(.cyan)
                    .font(.system(size: 14))
                Text("\(cachedGems)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.cyan.opacity(0.15))
            .cornerRadius(16)
            .scaleEffect(gemsScale)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 6)
        .background(Color(hex: "0A0F1C"))
        // Use onChange to update cached values only when they change, with animation
        .onChange(of: appState.progress?.hearts) { _, newValue in
            let oldValue = cachedHearts
            cachedHearts = newValue ?? 5
            if cachedHearts != oldValue {
                if cachedHearts > oldValue {
                    AppAudioManager.shared.playHeartGain()
                } else {
                    AppAudioManager.shared.playHeartLoss()
                }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    heartsScale = 1.3
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        heartsScale = 1.0
                    }
                }
            }
        }
        .onChange(of: appState.progress?.streakDays) { _, newValue in
            let oldValue = cachedStreak
            cachedStreak = newValue ?? 0
            if cachedStreak != oldValue {
                AppAudioManager.shared.playStreak()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    streakScale = 1.3
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        streakScale = 1.0
                    }
                }
            }
        }
        .onChange(of: appState.progress?.totalXP) { _, newValue in
            let oldValue = cachedXP
            cachedXP = newValue ?? 0
            if cachedXP != oldValue {
                AppAudioManager.shared.playSuccess()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    xpScale = 1.3
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        xpScale = 1.0
                    }
                }
            }
        }
        .onChange(of: appState.progress?.gems) { _, newValue in
            let oldValue = cachedGems
            cachedGems = newValue ?? 0
            if cachedGems != oldValue {
                AppAudioManager.shared.playGemEarn()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    gemsScale = 1.3
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        gemsScale = 1.0
                    }
                }
            }
        }
    }
}

// MARK: - Splash Screen
struct SplashScreen: View {
    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            // Solid background for faster initial paint
            Color(hex: "0A0F1C")
                .ignoresSafeArea()
            
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
        }
        // Pre-render for faster transitions
        .drawingGroup()
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
            // Performance: Disable automatic keyboard avoidance
            .ignoresSafeArea(.keyboard)
            
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

#Preview {
    ContentView()
        .environmentObject(AppState())
}
