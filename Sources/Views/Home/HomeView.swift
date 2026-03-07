import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var showInsights: Bool = false
    @State private var showGemStore: Bool = false
    @State private var gemPulse: Bool = false

    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                colors: [Color(hex: "06060F"), Color(hex: "0A0F1C"), Color(hex: "0D1526")],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    heroSection
                    levelSection
                    dailyLoginSection
                    dailyChallengesSection
                }
                .padding(.bottom, 110)
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
            RadialGradient(
                colors: [Color.purple.opacity(0.22), Color.clear],
                center: .top, startRadius: 0, endRadius: 280
            )
            .frame(height: 220)
            .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(greeting)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white.opacity(0.45))
                            .tracking(1.5)
                        Text(appState.currentUser?.displayName ?? "Focus Warrior")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Spacer()

                    // Gem counter
                    Button { showGemStore = true } label: {
                        HStack(spacing: 7) {
                            ZStack {
                                Circle()
                                    .fill(Color.cyan.opacity(0.18))
                                    .frame(width: 30, height: 30)
                                Image(systemName: "diamond.fill")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.cyan)
                                    .scaleEffect(gemPulse ? 1.15 : 1.0)
                            }
                            Text("\(appState.progress?.gems ?? 0)")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.06))
                                .overlay(Capsule().stroke(Color.cyan.opacity(0.35), lineWidth: 1))
                        )
                    }
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                            gemPulse = true
                        }
                    }

                    Button { appState.selectedTab = .profile } label: {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    colors: [Color(hex: "7C3AED"), Color(hex: "4F46E5")],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ))
                                .frame(width: 44, height: 44)
                            Text(appState.currentUser?.avatarEmoji ?? "🦞")
                                .font(.system(size: 22))
                        }
                    }
                    .padding(.leading, 10)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)

                HStack(spacing: 10) {
                    streakBadge
                    heartsBadge
                    Spacer()
                    Button { showInsights = true } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.purple)
                            Text("Stats")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(
                            Capsule()
                                .fill(Color.purple.opacity(0.12))
                                .overlay(Capsule().stroke(Color.purple.opacity(0.3), lineWidth: 1))
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 24)
            }
        }
    }

    var streakBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "flame.fill")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.orange)
            Text("\(appState.progress?.streakDays ?? 0) day streak")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(
            Capsule()
                .fill(Color.orange.opacity(0.1))
                .overlay(Capsule().stroke(Color.orange.opacity(0.28), lineWidth: 1))
        )
    }

    var heartsBadge: some View {
        HStack(spacing: 4) {
            ForEach(0..<5, id: \.self) { i in
                Image(systemName: i < (appState.progress?.hearts ?? 5) ? "heart.fill" : "heart")
                    .font(.system(size: 10))
                    .foregroundColor(i < (appState.progress?.hearts ?? 5) ? .red : .white.opacity(0.18))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(
            Capsule()
                .fill(Color.red.opacity(0.08))
                .overlay(Capsule().stroke(Color.red.opacity(0.22), lineWidth: 1))
        )
    }

    // MARK: - Level Section
    var levelSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [Color.purple.opacity(0.4), Color.indigo.opacity(0.2)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ), lineWidth: 1
                        )
                )

            VStack(spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("LEVEL \(appState.progress?.level ?? 1)")
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundColor(Color(hex: "A78BFA"))
                            .tracking(2)
                        Text(levelTitle)
                            .font(.system(size: 19, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.yellow)
                            Text("\(appState.progress?.totalXP ?? 0) XP")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Text("\(max(0, (appState.progress?.xpForNextLevel ?? 500) - (appState.progress?.currentLevelXP ?? 0))) to next level")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.35))
                    }
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(0.07))
                            .frame(height: 9)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(LinearGradient(
                                colors: [Color(hex: "7C3AED"), Color(hex: "06B6D4")],
                                startPoint: .leading, endPoint: .trailing
                            ))
                            .frame(width: geo.size.width * CGFloat(levelProgress), height: 9)
                            .animation(.spring(response: 0.6), value: levelProgress)
                    }
                }
                .frame(height: 9)
            }
            .padding(20)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
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
            // Daily Login Reward Card
            if let progress = appState.progress {
                if progress.canClaimDailyReward {
                    // Show claim button
                    DailyLoginRewardCard(
                        streakDays: progress.consecutiveLoginDays,
                        reward: progress.currentDayReward,
                        onClaim: {
                            claimDailyReward()
                        }
                    )
                } else {
                    // Show already claimed state
                    DailyLoginStreakCard(
                        streakDays: progress.consecutiveLoginDays,
                        daysUntilBonus: progress.daysUntilWeeklyBonus
                    )
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
    
    func claimDailyReward() {
        guard var progress = appState.progress else { return }
        let reward = progress.claimDailyReward()
        appState.progress = progress
        
        // Show reward animation/notification
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
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("TODAY'S CHALLENGES")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundColor(.white.opacity(0.35))
                        .tracking(2)
                    Text("Daily Training")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                Spacer()
                Text(formattedDate)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(.horizontal, 20)

            VStack(spacing: 10) {
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
            RoundedRectangle(cornerRadius: 18)
                .fill(done ? Color.green.opacity(0.1) : Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(done ? Color.green.opacity(0.35) : Color.white.opacity(0.07), lineWidth: 1)
                )
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(done ? Color.green.opacity(0.18) : Color.white.opacity(0.06))
                        .frame(width: 44, height: 44)
                    Image(systemName: done ? "checkmark.circle.fill" : "target")
                        .font(.system(size: 20))
                        .foregroundColor(done ? .green : .white.opacity(0.55))
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(done ? "Daily Goal Complete! 🎉" : "Daily Goal")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    Text(done ? "Bonus gems awarded" : "Complete \(3 - completed) more challenge\(3 - completed == 1 ? "" : "s")")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.45))
                }
                Spacer()
                Text("\(completed)/3")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(done ? .green : .white)
            }
            .padding(16)
        }
    }
}

// MARK: - Home Daily Challenge Card
struct HomeDailyChallengeCard: View {
    let challenge: AllChallengeType
    let isCompleted: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(challenge.color.opacity(isCompleted ? 0.1 : 0.18))
                        .frame(width: 52, height: 52)
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : challenge.icon)
                        .font(.system(size: isCompleted ? 24 : 22))
                        .foregroundColor(challenge.color.opacity(isCompleted ? 0.5 : 1))
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isCompleted ? .white.opacity(0.4) : .white)
                    HStack(spacing: 8) {
                        Text(challenge.category.rawValue)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(challenge.color.opacity(isCompleted ? 0.4 : 0.85))
                        Circle().fill(Color.white.opacity(0.2)).frame(width: 3, height: 3)
                        HStack(spacing: 3) {
                            Image(systemName: "diamond.fill")
                                .font(.system(size: 9))
                                .foregroundColor(.cyan.opacity(isCompleted ? 0.3 : 0.75))
                            Text("+\(challenge.gemReward) gems")
                                .font(.system(size: 11))
                                .foregroundColor(.cyan.opacity(isCompleted ? 0.3 : 0.7))
                        }
                    }
                }
                Spacer()
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white.opacity(0.25))
                } else {
                    ZStack {
                        Circle().fill(Color.green.opacity(0.15)).frame(width: 36, height: 36)
                        Image(systemName: "play.fill")
                            .font(.system(size: 13))
                            .foregroundColor(.green)
                    }
                }
            }
            .padding(15)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isCompleted ? Color.white.opacity(0.02) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(challenge.color.opacity(isCompleted ? 0.08 : 0.22), lineWidth: 1)
                    )
            )
        }
        .disabled(isCompleted)
    }
}

// MARK: - Gem Store View
struct GemStoreView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

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
                    }
                    .padding(.horizontal, 20).padding(.bottom, 40)
                }
            }
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
                // Glow effect
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.25), Color.orange.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Border
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [Color.purple, Color.orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                
                // Content
                HStack(spacing: 16) {
                    // Gift icon with animation
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.purple, .orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 56, height: 56)
                            .scaleEffect(pulse ? 1.1 : 1.0)
                        
                        Image(systemName: "gift.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("DAILY REWARD")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundColor(.purple)
                            .tracking(2)
                        
                        Text(dayText)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 12) {
                            HStack(spacing: 4) {
                                Image(systemName: "diamond.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.cyan)
                                Text("\(reward.gems)")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.cyan)
                            }
                            
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.yellow)
                                Text("\(reward.xp) XP")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Claim button
                    Text("CLAIM")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                colors: [.purple, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(20)
                }
                .padding(18)
            }
        }
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
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            
            HStack(spacing: 14) {
                // Flame icon
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 48, height: 48)
                    Image(systemName: "flame.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.orange)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("LOGIN STREAK")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundColor(.orange)
                        .tracking(2)
                    
                    Text(streakText)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    if daysUntilBonus > 0 {
                        Text("\(daysUntilBonus) day\(daysUntilBonus == 1 ? "" : "s") until weekly bonus!")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.5))
                    } else {
                        Text("🎉 Weekly bonus earned!")
                            .font(.system(size: 12))
                            .foregroundColor(.yellow)
                    }
                }
                
                Spacer()
                
                // Checkmark
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.green)
            }
            .padding(16)
        }
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
