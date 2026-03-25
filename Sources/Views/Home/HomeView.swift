import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var purchaseService = PurchaseService.shared
    @State private var showInsights: Bool = false
    @State private var showGemStore: Bool = false
    @State private var gemPulse: Bool = false

    var body: some View {
        ZStack(alignment: .top) {
            // Background gradient with ambient glow
            LinearGradient(
                colors: [Color(hex: "06060F"), Color(hex: "0A0F1C"), Color(hex: "0D1526")],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            // Ambient glow orbs in background
            ZStack {
                Circle()
                    .fill(RadialGradient(
                        colors: [Color.purple.opacity(0.15), Color.clear],
                        center: .init(x: 0.2, y: 0.1),
                        startRadius: 0,
                        endRadius: 200
                    ))
                    .ignoresSafeArea()

                Circle()
                    .fill(RadialGradient(
                        colors: [Color.cyan.opacity(0.12), Color.clear],
                        center: .init(x: 0.8, y: 0.5),
                        startRadius: 0,
                        endRadius: 180
                    ))
                    .ignoresSafeArea()
            }
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    heroSection
                    levelSection
                    dailyLoginSection
                    dailyChallengesSection
                    if !purchaseService.noAdsEnabled {
                        sponsorBanner
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                    }
                }
                .padding(.bottom, 120)
            }
        }
        .sheet(isPresented: $showInsights) {
            InsightsView()
        }
        .sheet(isPresented: $showGemStore) {
            GemStoreView()
        }
    }

    // MARK: - Hero Section
    var heroSection: some View {
        ZStack(alignment: .bottom) {
            // Large radial gradient glow
            RadialGradient(
                colors: [Color.purple.opacity(0.28), Color.cyan.opacity(0.08), Color.clear],
                center: .top, startRadius: 0, endRadius: 320
            )
            .frame(height: 240)
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top greeting and avatar row
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(greeting)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white.opacity(0.45))
                            .tracking(1.5)
                        Text(appState.currentUser?.displayName ?? "Focus Warrior")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Spacer()

                    // Avatar button with gradient background
                    Button { appState.selectedTab = .profile } label: {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    colors: [Color(hex: "7C3AED"), Color(hex: "4F46E5")],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ))
                                .frame(width: 48, height: 48)
                                .shadow(color: Color(hex: "7C3AED").opacity(0.4), radius: 12, x: 0, y: 4)
                            Text(appState.currentUser?.avatarEmoji ?? "🦞")
                                .font(.system(size: 24))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 58)

                // Gem counter and stats pills
                HStack(spacing: 10) {
                    // Gem pill with liquid glass effect
                    Button { showGemStore = true } label: {
                        HStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color.cyan.opacity(0.2))
                                    .frame(width: 32, height: 32)
                                Image(systemName: "diamond.fill")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.cyan)
                                    .scaleEffect(gemPulse ? 1.15 : 1.0)
                            }
                            Text("\(appState.progress?.gems ?? 0)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.06))
                                .overlay(Capsule().stroke(Color.cyan.opacity(0.4), lineWidth: 1.2))
                        )
                        .shadow(color: Color.cyan.opacity(0.25), radius: 8, x: 0, y: 2)
                    }
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                            gemPulse = true
                        }
                    }

                    streakBadge
                    heartsBadge

                    Spacer()

                    // Stats button
                    Button { showInsights = true } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.purple)
                            Text("Stats")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.purple.opacity(0.15))
                                .overlay(Capsule().stroke(Color.purple.opacity(0.35), lineWidth: 1))
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 24)
            }
        }
    }

    var streakBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "flame.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.orange)
            Text("\(appState.progress?.streakDays ?? 0) day")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.orange.opacity(0.12))
                .overlay(Capsule().stroke(Color.orange.opacity(0.35), lineWidth: 1.1))
        )
        .shadow(color: Color.orange.opacity(0.2), radius: 6, x: 0, y: 2)
    }

    var heartsBadge: some View {
        HStack(spacing: 4) {
            ForEach(0..<5, id: \.self) { i in
                Image(systemName: i < (appState.progress?.hearts ?? 5) ? "heart.fill" : "heart")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(i < (appState.progress?.hearts ?? 5) ? .red : .white.opacity(0.18))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.red.opacity(0.10))
                .overlay(Capsule().stroke(Color.red.opacity(0.28), lineWidth: 1.1))
        )
        .shadow(color: Color.red.opacity(0.15), radius: 6, x: 0, y: 2)
    }

    // MARK: - Level Section
    var levelSection: some View {
        VStack(spacing: 0) {
            ZStack {
                // Liquid glass background
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white.opacity(0.04))
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.ultraThinMaterial)
                    )

                // Gradient overlay
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.08), Color.cyan.opacity(0.04)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )

                // Specular highlight
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.15), Color.white.opacity(0)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 1)
                    .padding(1)

                // Gradient border
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.4), Color.cyan.opacity(0.2)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ), lineWidth: 1.5
                    )

                // Content
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("LEVEL \(appState.progress?.level ?? 1)")
                                .font(.system(size: 11, weight: .black, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(hex: "C084FC"), Color(hex: "A78BFA")],
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                )
                                .tracking(2)
                            Text(levelTitle)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 3) {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.yellow)
                                Text("\(appState.progress?.totalXP ?? 0) XP")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            Text("\(max(0, (appState.progress?.xpForNextLevel ?? 500) - (appState.progress?.currentLevelXP ?? 0))) to next")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.4))
                        }
                    }

                    // XP Progress bar with glow
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            // Background track
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.08))

                            // Glow effect behind progress
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.purple.opacity(0.4), Color.cyan.opacity(0.3)],
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * CGFloat(levelProgress), height: 10)
                                .blur(radius: 6)
                                .opacity(0.6)

                            // Main progress fill
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "7C3AED"), Color(hex: "06B6D4")],
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * CGFloat(levelProgress), height: 10)
                                .shadow(color: Color.cyan.opacity(0.4), radius: 8, x: 0, y: 2)
                                .animation(.spring(response: 0.6), value: levelProgress)
                        }
                    }
                    .frame(height: 10)
                }
                .padding(20)
            }
            .frame(height: 160)
            .shadow(color: Color.purple.opacity(0.15), radius: 12, x: 0, y: 4)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    var levelProgress: Double {
        guard let progress = appState.progress else { return 0 }
        return min(Double(progress.currentLevelXP) / Double(max(progress.xpForNextLevel, 1)), 1.0)
    }

    var levelTitle: String {
        switch appState.progress?.level ?? 1 {
        case 1...3:  return "Awakening Mind"
        case 4...7:  return "Focus Seeker"
        case 8...14: return "Attention Adept"
        case 15...24: return "Clarity Hunter"
        case 25...39: return "Mind Architect"
        case 40...59: return "Focus Virtuoso"
        case 60...79: return "Neural Sage"
        default:     return "Flow Master"
        }
    }

    // MARK: - Daily Login Rewards Section
    var dailyLoginSection: some View {
        VStack(spacing: 12) {
            if let progress = appState.progress {
                if progress.canClaimDailyReward {
                    DailyLoginRewardCard(
                        streakDays: progress.consecutiveLoginDays,
                        reward: progress.currentDayReward,
                        onClaim: {
                            claimDailyReward()
                        }
                    )
                } else {
                    DailyLoginStreakCard(
                        streakDays: progress.consecutiveLoginDays,
                        daysUntilBonus: progress.daysUntilWeeklyBonus
                    )
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    func claimDailyReward() {
        guard var progress = appState.progress else { return }
        let reward = progress.claimDailyReward()
        appState.progress = progress

        showRewardNotification = true
        pendingReward = reward
    }

    @State private var showRewardNotification = false
    @State private var pendingReward: (gems: Int, xp: Int) = (0, 0)

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "GOOD MORNING"
        case 12..<17: return "GOOD AFTERNOON"
        case 17..<21: return "GOOD EVENING"
        default:      return "NIGHT MODE"
        }
    }

    // MARK: - Daily Challenges Section
    var dailyChallengesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 3) {
                Text("TODAY'S CHALLENGES")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundColor(.white.opacity(0.35))
                    .tracking(2)
                Text("Daily Training")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 4)

            VStack(spacing: 12) {
                ForEach(dailyChallenges, id: \.self) { challenge in
                    HomeDailyChallengeCard(
                        challenge: challenge,
                        isCompleted: isCompleted(challenge)
                    ) {
                        appState.selectedChallenge = challenge
                        appState.startChallengeFromPath = true
                        appState.selectedTab = .practice
                    }
                }
            }
            .padding(.horizontal, 20)

            dailyGoalBanner
                .padding(.horizontal, 20)
        }
        .padding(.top, 28)
    }

    var dailyChallenges: [AllChallengeType] {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let all = AllChallengeType.allCases
        let s = (day - 1) % all.count
        return [all[s % all.count], all[(s + 8) % all.count], all[(s + 16) % all.count]]
    }

    func isCompleted(_ challenge: AllChallengeType) -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return appState.progress?.completedChallenges.contains {
            $0.challengeTypeRaw == challenge.rawValue &&
            Calendar.current.startOfDay(for: $0.attemptedAt) == today
        } ?? false
    }

    var formattedDate: String {
        let f = DateFormatter(); f.dateFormat = "MMM d"; return f.string(from: Date())
    }

    var dailyGoalBanner: some View {
        let completed = dailyChallenges.filter { isCompleted($0) }.count
        let done = completed >= 3
        return ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: done ? [Color.green.opacity(0.12), Color.green.opacity(0.04)] : [Color.white.opacity(0.05), Color.white.opacity(0.02)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                )

            RoundedRectangle(cornerRadius: 20)
                .stroke(done ? Color.green.opacity(0.4) : Color.white.opacity(0.1), lineWidth: 1.5)

            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(done ? Color.green.opacity(0.2) : Color.white.opacity(0.08))
                        .frame(width: 48, height: 48)
                    Image(systemName: done ? "checkmark.circle.fill" : "target")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(done ? .green : .white.opacity(0.6))
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(done ? "GOAL COMPLETE!" : "DAILY GOAL")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundColor(done ? .green : .white.opacity(0.5))
                        .tracking(1.5)
                    Text(done ? "Bonus gems awarded" : "Complete \(3 - completed) more")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                Spacer()
                Text("\(completed)/3")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(done ? .green : .white)
                    .padding(.trailing, 4)
            }
            .padding(16)
        }
        .shadow(color: done ? Color.green.opacity(0.2) : Color.clear, radius: 10, x: 0, y: 4)
    }

    var sponsorBanner: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.orange.opacity(0.09))
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                )

            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orange.opacity(0.25), lineWidth: 1.2)

            HStack(spacing: 12) {
                Image(systemName: "megaphone.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.orange)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Remove Ads")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                    Text("Cleaner training flow, better focus")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.6))
                }
                Spacer()
                Button("Upgrade") { showGemStore = true }
                    .font(.system(size: 12, weight: .semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(
                        LinearGradient(
                            colors: [Color.orange.opacity(0.3), Color.orange.opacity(0.15)],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(14)
        }
        .shadow(color: Color.orange.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Home Daily Challenge Card
struct HomeDailyChallengeCard: View {
    let challenge: AllChallengeType
    let isCompleted: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                // Liquid glass background
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [challenge.color.opacity(isCompleted ? 0.06 : 0.1), challenge.color.opacity(isCompleted ? 0.02 : 0.04)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                    )

                // Specular highlight
                VStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.12), Color.white.opacity(0)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 1)
                    Spacer()
                }
                .padding(1)

                // Gradient border
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [challenge.color.opacity(isCompleted ? 0.1 : 0.25), challenge.color.opacity(isCompleted ? 0.05 : 0.15)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ), lineWidth: 1.5
                    )

                // Content
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [challenge.color.opacity(isCompleted ? 0.12 : 0.2), challenge.color.opacity(isCompleted ? 0.05 : 0.08)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 56, height: 56)
                            .shadow(color: challenge.color.opacity(isCompleted ? 0.1 : 0.3), radius: 8, x: 0, y: 2)
                        Image(systemName: isCompleted ? "checkmark.circle.fill" : challenge.icon)
                            .font(.system(size: isCompleted ? 26 : 24, weight: .semibold))
                            .foregroundColor(challenge.color.opacity(isCompleted ? 0.5 : 1))
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        Text(challenge.rawValue)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(isCompleted ? .white.opacity(0.5) : .white)

                        HStack(spacing: 8) {
                            Text(challenge.category.rawValue)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(challenge.color.opacity(isCompleted ? 0.35 : 0.8))
                            Circle().fill(Color.white.opacity(0.15)).frame(width: 3.5, height: 3.5)
                            HStack(spacing: 3) {
                                Image(systemName: "diamond.fill")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(.cyan.opacity(isCompleted ? 0.3 : 0.8))
                                Text("+\(challenge.gemReward)")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.cyan.opacity(isCompleted ? 0.3 : 0.75))
                            }
                        }
                    }

                    Spacer()

                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white.opacity(0.25))
                            .padding(.trailing, 4)
                    } else {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.green.opacity(0.25), Color.green.opacity(0.12)],
                                        startPoint: .topLeading, endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 40, height: 40)
                                .shadow(color: Color.green.opacity(0.3), radius: 8, x: 0, y: 2)
                            Image(systemName: "play.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.green)
                        }
                    }
                }
                .padding(16)
            }
            .frame(height: 80)
            .shadow(color: challenge.color.opacity(isCompleted ? 0.08 : 0.15), radius: 12, x: 0, y: 4)
        }
        .disabled(isCompleted)
    }
}

// MARK: - Gem Store View
struct GemStoreView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @StateObject private var purchaseService = PurchaseService.shared

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "06060F"), Color(hex: "0A0F1C")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white.opacity(0.6))
                            .frame(width: 34, height: 34)
                            .background(Circle().fill(Color.white.opacity(0.08)))
                    }
                    Spacer()
                    Text("Gem Store")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    HStack(spacing: 5) {
                        Image(systemName: "diamond.fill").font(.system(size: 11)).foregroundColor(.cyan)
                        Text("\(appState.progress?.gems ?? 0)").font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                    }
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(Capsule().fill(Color.cyan.opacity(0.12)))
                }
                .padding(.horizontal, 20).padding(.top, 20).padding(.bottom, 28)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        ZStack {
                            Circle().fill(Color.cyan.opacity(0.1)).frame(width: 100, height: 100)
                            Image(systemName: "diamond.fill").font(.system(size: 44)).foregroundColor(.cyan)
                        }.padding(.bottom, 4)

                        Text("Power up with your gems")
                            .font(.system(size: 15)).foregroundColor(.white.opacity(0.45))
                            .padding(.bottom, 12)

                        gemItem(icon: "heart.fill", color: .red, title: "Restore Heart",
                                subtitle: "Refill 1 life", cost: 50) { _ = appState.purchaseHeart() }
                        gemItem(icon: "snowflake", color: .blue, title: "Streak Freeze",
                                subtitle: "Protect streak for 1 day", cost: 100) { _ = appState.purchaseStreakFreeze() }
                        gemItem(icon: "clock.arrow.circlepath", color: .green, title: "Refill Slot",
                                subtitle: "Add a heart refill slot", cost: 25) { _ = appState.purchaseRefillSlot() }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("In-App Purchases")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.top, 8)
                            purchaseItem(
                                icon: "diamond.fill",
                                color: .cyan,
                                title: "250 Gems",
                                subtitle: "Instant gem bundle",
                                price: purchaseService.displayPrice(for: .gemsSmall)
                            ) { purchase(.gemsSmall) }
                            purchaseItem(
                                icon: "diamond.circle.fill",
                                color: .cyan,
                                title: "1200 Gems",
                                subtitle: "Best value bundle",
                                price: purchaseService.displayPrice(for: .gemsMedium)
                            ) { purchase(.gemsMedium) }
                            purchaseItem(
                                icon: "nosign",
                                color: .orange,
                                title: "No Ads",
                                subtitle: purchaseService.noAdsEnabled ? "Already unlocked" : "Remove sponsored banners",
                                price: purchaseService.noAdsEnabled ? "Enabled" : purchaseService.displayPrice(for: .noAds)
                            ) { if !purchaseService.noAdsEnabled { purchase(.noAds) } }
                        }
                    }
                    .padding(.horizontal, 20).padding(.bottom, 40)
                }
            }
        }
        .task {
            await purchaseService.loadProductsIfNeeded()
        }
    }

    func gemItem(icon: String, color: Color, title: String, subtitle: String, cost: Int, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12).fill(color.opacity(0.15)).frame(width: 50, height: 50)
                    Image(systemName: icon).font(.system(size: 22)).foregroundColor(color)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(title).font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                    Text(subtitle).font(.system(size: 12)).foregroundColor(.white.opacity(0.4))
                }
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "diamond.fill").font(.system(size: 10)).foregroundColor(.cyan)
                    Text("\(cost)").font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                }
                .padding(.horizontal, 12).padding(.vertical, 8)
                .background(Capsule().fill(Color.cyan.opacity(0.14)))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(0.04))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.08), lineWidth: 1))
            )
        }
    }

    func purchaseItem(icon: String, color: Color, title: String, subtitle: String, price: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12).fill(color.opacity(0.15)).frame(width: 50, height: 50)
                    Image(systemName: icon).font(.system(size: 20)).foregroundColor(color)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(title).font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                    Text(subtitle).font(.system(size: 12)).foregroundColor(.white.opacity(0.45))
                }
                Spacer()
                Text(price)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.white.opacity(0.12)))
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.04)))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
        }
    }

    func purchase(_ product: AppProductID) {
        Task {
            _ = await purchaseService.purchase(product, appState: appState)
        }
    }
}

// MARK: - Daily Login Reward Card
struct DailyLoginRewardCard: View {
    let streakDays: Int
    let reward: (gems: Int, xp: Int)
    let onClaim: () -> Void

    @State private var pulse = false

    var body: some View {
        Button(action: onClaim) {
            ZStack {
                // Liquid glass background with gradient
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.12), Color.orange.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.ultraThinMaterial)
                    )

                // Specular highlight
                VStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.15), Color.white.opacity(0)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 1)
                    Spacer()
                }
                .padding(1)

                // Gradient border
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.4), Color.orange.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )

                HStack(spacing: 16) {
                    // Gift icon with pulse animation
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "7C3AED"), Color(hex: "FB923C")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                            .scaleEffect(pulse ? 1.12 : 1.0)
                            .shadow(color: Color.purple.opacity(0.4), radius: 12, x: 0, y: 4)

                        Image(systemName: "gift.fill")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        Text("DAILY REWARD")
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundColor(.purple)
                            .tracking(2)

                        Text(dayText)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)

                        HStack(spacing: 14) {
                            HStack(spacing: 4) {
                                Image(systemName: "diamond.fill")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.cyan)
                                Text("\(reward.gems)")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.cyan)
                            }

                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.yellow)
                                Text("\(reward.xp) XP")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.yellow)
                            }
                        }
                    }

                    Spacer()

                    // Claim button with gradient
                    Text("CLAIM")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "7C3AED"), Color(hex: "FB923C")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: Color.purple.opacity(0.3), radius: 8, x: 0, y: 2)
                }
                .padding(18)
            }
        }
        .frame(height: 100)
        .shadow(color: Color.purple.opacity(0.2), radius: 14, x: 0, y: 6)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }

    var dayText: String {
        if streakDays == 0 || streakDays == 1 {
            return "Day 1 Reward"
        } else if streakDays <= 7 {
            return "Day \(streakDays) Reward"
        } else {
            let cycle = ((streakDays - 1) % 7) + 1
            return "Day \(cycle) Reward"
        }
    }
}

// MARK: - Daily Login Streak Card (Already Claimed)
struct DailyLoginStreakCard: View {
    let streakDays: Int
    let daysUntilBonus: Int

    var body: some View {
        ZStack {
            // Liquid glass background
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.orange.opacity(0.08))
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                )

            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.orange.opacity(0.25), lineWidth: 1.2)

            HStack(spacing: 14) {
                // Flame icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.25), Color.orange.opacity(0.1)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 52, height: 52)
                        .shadow(color: Color.orange.opacity(0.25), radius: 8, x: 0, y: 2)
                    Image(systemName: "flame.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.orange)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("LOGIN STREAK")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundColor(.orange)
                        .tracking(2)

                    Text(streakText)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)

                    if daysUntilBonus > 0 {
                        Text("\(daysUntilBonus) day\(daysUntilBonus == 1 ? "" : "s") until weekly bonus")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                    } else {
                        Text("Weekly bonus earned!")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.yellow)
                    }
                }

                Spacer()

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(.green)
                    .shadow(color: Color.green.opacity(0.3), radius: 8, x: 0, y: 2)
            }
            .padding(16)
        }
        .frame(height: 90)
        .shadow(color: Color.orange.opacity(0.15), radius: 10, x: 0, y: 4)
    }

    var streakText: String {
        if streakDays == 1 {
            return "1 Day - Keep it up!"
        } else if streakDays < 7 {
            return "\(streakDays) Days - Great!"
        } else if streakDays == 7 {
            return "1 Week Strong! 🔥"
        } else {
            let weeks = streakDays / 7
            let days = streakDays % 7
            if days == 0 {
                return "\(weeks) Weeks!"
            } else {
                return "\(weeks)w \(days)d Streak"
            }
        }
    }
}

#Preview {
    HomeView().environmentObject(AppState())
}
