import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var themeService: ThemeService

    var body: some View {
        ZStack {
            LinearGradient(
                colors: themeService.selectedTheme.gradientColors,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .drawingGroup()

            if appState.isLoading {
                SplashScreen()
            } else if !appState.isOnboarded {
                OnboardingFlowView()
            } else {
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.isOnboarded)
    }
}

// MARK: - Splash Screen
struct SplashScreen: View {
    @State private var scale: CGFloat = 0.4
    @State private var opacity: Double = 0
    @State private var rotation: Double = -15
    @State private var glowPulse = false

    var body: some View {
        ZStack {
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.18))
                    .frame(width: 320, height: 320)
                    .blur(radius: 60)
                    .offset(x: -60, y: -80)
                Circle()
                    .fill(Color.indigo.opacity(0.15))
                    .frame(width: 260, height: 260)
                    .blur(radius: 50)
                    .offset(x: 80, y: 60)
            }
            .scaleEffect(glowPulse ? 1.08 : 0.95)
            .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: glowPulse)

            VStack(spacing: 28) {
                ZStack {
                    Circle()
                        .stroke(Color.purple.opacity(glowPulse ? 0.25 : 0.12), lineWidth: 1.5)
                        .frame(width: 200, height: 200)
                        .blur(radius: 2)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: glowPulse)

                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color.purple.opacity(0.7), Color.cyan.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 160, height: 160)

                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 130, height: 130)
                        .overlay(
                            Circle().fill(
                                LinearGradient(
                                    colors: [Color.purple.opacity(0.4), Color.indigo.opacity(0.3)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            )
                        )
                        .overlay(
                            Circle().fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.3), Color.clear],
                                    startPoint: .topLeading, endPoint: .center
                                )
                            )
                        )
                        .shadow(color: .purple.opacity(0.5), radius: 30)

                    Image(systemName: "xmark")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, Color.white.opacity(0.8)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .shadow(color: .white.opacity(0.3), radius: 8)
                }
                .scaleEffect(scale)
                .rotationEffect(.degrees(rotation))
                .opacity(opacity)

                VStack(spacing: 6) {
                    Text("Unscroll")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, Color.white.opacity(0.85)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                    Text("Reclaim Your Focus")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.45))
                        .tracking(1.5)
                }
                .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.9, dampingFraction: 0.65)) {
                scale = 1.0
                opacity = 1.0
                rotation = 0
            }
            glowPulse = true
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $appState.selectedTab) {
                HomeView()
                    .tag(AppState.Tab.home)
                    .id(AppState.Tab.home)

                WindingProgressPath()
                    .tag(AppState.Tab.path)
                    .id(AppState.Tab.path)

                ScreenTimeDashboardView()
                    .tag(AppState.Tab.screenTime)
                    .id(AppState.Tab.screenTime)

                PracticeView()
                    .tag(AppState.Tab.practice)
                    .id(AppState.Tab.practice)

                ProfileView()
                    .tag(AppState.Tab.profile)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea(edges: .bottom)

            // Floating Glass Tab Bar
            FloatingTabBar(selectedTab: $appState.selectedTab)
        }
    }
}

// MARK: - Floating Glass Tab Bar
struct FloatingTabBar: View {
    @Binding var selectedTab: AppState.Tab

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(AppState.Tab.allCases, id: \.self) { tab in
                    GlassTabButton(
                        tab: tab,
                        isActive: selectedTab == tab
                    ) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            selectedTab = tab
                        }
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 32)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: 32)
                        .fill(Color(hex: "0A0F1C").opacity(0.55))
                    VStack {
                        RoundedRectangle(cornerRadius: 32)
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.14), Color.clear],
                                    startPoint: .top, endPoint: .bottom
                                )
                            )
                            .frame(height: 24)
                        Spacer(minLength: 0)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 32))
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.22),
                                Color.purple.opacity(0.18),
                                Color.white.opacity(0.07)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.45), radius: 28, y: 10)
            .shadow(color: Color.purple.opacity(0.12), radius: 20)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
        .background(
            LinearGradient(
                colors: [Color.clear, Color(hex: "06060F").opacity(0.75)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .bottom)
            .allowsHitTesting(false)
        )
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
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
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
        .environmentObject(ThemeService.shared)
}
