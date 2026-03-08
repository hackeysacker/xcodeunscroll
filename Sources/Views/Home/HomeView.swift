import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var showChallengePicker: Bool = false
    @State private var showInsights: Bool = false
    @State private var showLeaderboard: Bool = false
    @State private var isRefreshing: Bool = false
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "0A0F1C"), Color(hex: "1E293B")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Header
                    header
                    
                    // Level progress card
                    levelProgressCard
                    
                    // Stats row
                    statsRow
                    
                    // Quick actions
                    quickActions
                    
                    // Daily goal
                    dailyGoalCard
                    
                    // Recent activity
                    recentActivitySection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 100)
            }
            .refreshable {
                await refreshData()
            }
            
            // Loading overlay when syncing
            if isRefreshing || appState.isSyncing {
                VStack {
                    Spacer()
                    HStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                        Text("Syncing...")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(8)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(8)
                    .padding(.bottom, 120)
                }
            }
        }
        .sheet(isPresented: $showInsights) {
            InsightsView()
        }
        .sheet(isPresented: $showLeaderboard) {
            LeaderboardView()
        }
    }
    
    // MARK: - Pull to Refresh
    private func refreshData() async {
        isRefreshing = true
        // Simulate network delay for smooth UX
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        if let userId = appState.currentUser?.id {
            await appState.syncFullProgressFromCloud(userId: userId)
        }
        
        isRefreshing = false
    }
    
    // MARK: - Header
    var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                Text(appState.currentUser?.displayName ?? "Focus Warrior")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Gems
            HStack(spacing: 4) {
                Image(systemName: "gem.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.cyan)
                Text("\(appState.progress?.gems ?? 0)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.cyan.opacity(0.15))
            .cornerRadius(16)
            
            // Profile avatar
            Button {
                appState.selectedTab = .profile
            } label: {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.purple, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 50, height: 50)
                    Text(appState.currentUser?.avatarEmoji ?? "🦞")
                        .font(.system(size: 24))
                }
            }
        }
        .padding(.top, 12)
    }
    
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning! ☀️"
        case 12..<17: return "Good afternoon! 🌤️"
        case 17..<21: return "Good evening! 🌙"
        default: return "Night owl! 🦉"
        }
    }
    
    // MARK: - Level Progress Card
    var levelProgressCard: some View {
        GlassCard(cornerRadius: 20) {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Level \(appState.progress?.level ?? 1)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.purple)
                        
                        Text("Keep going!")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // XP and Gems badges
                    HStack(spacing: 12) {
                        // Gems
                        HStack(spacing: 4) {
                            Image(systemName: "gem.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.cyan)
                            Text("\(appState.progress?.gems ?? 0)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        // XP
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.yellow)
                            Text("\(appState.progress?.totalXP ?? 0)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                
                // Progress bar - simplified
                VStack(spacing: 6) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.1))
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing))
                                .frame(width: min(geo.size.width * levelProgress, geo.size.width))
                        }
                    }
                    .frame(height: 10)
                    
                    // XP text
                    HStack {
                        Text("\(appState.progress?.currentLevelXP ?? 0) XP")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(max(0, (appState.progress?.xpForNextLevel ?? 1000) - (appState.progress?.currentLevelXP ?? 0))) to next")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
    
    var levelProgress: CGFloat {
        guard let progress = appState.progress else { return 0 }
        return CGFloat(progress.currentLevelXP) / CGFloat(max(progress.xpForNextLevel, 1))
    }
    
    // MARK: - Stats Row
    var statsRow: some View {
        HStack(spacing: 12) {
            // Streak
            GlassCard(cornerRadius: 16) {
                VStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.orange)
                    Text("\(appState.progress?.streakDays ?? 0)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    Text("Day Streak")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
            }
            
            // Hearts
            GlassCard(cornerRadius: 16) {
                VStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.red)
                    Text("\(appState.progress?.hearts ?? 5)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    Text("Hearts")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
            }
            
            // Gems
            GlassCard(cornerRadius: 16) {
                VStack(spacing: 8) {
                    Image(systemName: "gem.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.cyan)
                    Text("\(appState.progress?.gems ?? 0)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    Text("Gems")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    // MARK: - Quick Actions
    var quickActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                // Start Training
                QuickActionCard(
                    icon: "play.fill",
                    title: "Start",
                    subtitle: "Train now",
                    color: .green
                ) {
                    appState.selectedTab = .practice
                }
                
                // View Stats
                QuickActionCard(
                    icon: "chart.bar.fill",
                    title: "Stats",
                    subtitle: "Insights",
                    color: .cyan
                ) {
                    showInsights = true
                }
                
                // Leaderboard
                QuickActionCard(
                    icon: "trophy.fill",
                    title: "Rank",
                    subtitle: "Leaderboard",
                    color: .yellow
                ) {
                    showLeaderboard = true
                }
                
                // Focus Mode
                QuickActionCard(
                    icon: "shield.fill",
                    title: "Focus",
                    subtitle: "Shield",
                    color: .purple
                ) {
                    appState.selectedTab = .screenTime
                }
            }
        }
    }
    
    // MARK: - Daily Goal
    var dailyGoalCard: some View {
        VStack(spacing: 12) {
            // Daily Challenges Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily Challenges")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    Text("Complete all 3 for bonus rewards!")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Progress
                HStack(spacing: 4) {
                    Image(systemName: appState.allDailyChallengesCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(appState.allDailyChallengesCompleted ? .green : .gray)
                    Text("\(appState.dailyChallengeProgress.completed)/3")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(appState.allDailyChallengesCompleted ? .green : .white)
                }
            }
            
            // Daily Challenges List
            let dailyChallenges = appState.getDailyChallenges()
            ForEach(dailyChallenges) { challenge in
                DailyChallengeRow(challenge: challenge) {
                    appState.selectedChallenge = challenge.challengeType
                    appState.startChallengeFromPath = true
                    appState.selectedTab = .practice
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "1E293B").opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(appState.allDailyChallengesCompleted ? Color.green.opacity(0.5) : Color.purple.opacity(0.3), lineWidth: 1)
        )
    }
    
    var dailyGoalCompleted: Int {
        appState.dailyChallengeProgress.completed
    }
    
    var dailyGoalProgress: Double {
        let completed = appState.dailyChallengeProgress.completed
        return min(Double(completed) / 3.0, 1.0)
    }
    
    // MARK: - Recent Activity
    var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Activity")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Button("See All") {
                    showInsights = true
                }
                .font(.system(size: 14))
                .foregroundColor(.purple)
            }
            
            if let challenges = appState.progress?.completedChallenges, !challenges.isEmpty {
                let recent = Array(challenges.suffix(3).reversed())
                ForEach(recent) { challenge in
                    RecentActivityRow(challenge: challenge)
                }
            } else {
                GlassCard(cornerRadius: 12) {
                    HStack {
                        Image(systemName: "clock")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                        Text("No recent activity. Start a challenge!")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            }
        }
    }
}

// MARK: - Quick Action Card
struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(color)
                }
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - Recent Activity Row
struct RecentActivityRow: View {
    let challenge: ChallengeAttempt
    
    var body: some View {
        GlassCard(cornerRadius: 12) {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(scoreColor.opacity(0.2))
                        .frame(width: 44, height: 44)
                    Image(systemName: challenge.isPerfect ? "star.fill" : "checkmark")
                        .font(.system(size: 18))
                        .foregroundColor(scoreColor)
                }
                
                // Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(challenge.challengeTypeRaw)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    Text(formattedDate)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Score & XP
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(challenge.score)%")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(scoreColor)
                    Text("+\(challenge.xpEarned) XP")
                        .font(.system(size: 12))
                        .foregroundColor(.yellow)
                }
            }
        }
    }
    
    var scoreColor: Color {
        if challenge.score >= 90 { return .green }
        if challenge.score >= 70 { return .yellow }
        return .orange
    }
    
    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: challenge.attemptedAt, relativeTo: Date())
    }
}

// MARK: - Daily Challenge Row

struct DailyChallengeRow: View {
    let challenge: DailyChallenge
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(challenge.isCompleted ? Color.green.opacity(0.2) : categoryColor.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    if challenge.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: challenge.icon)
                            .font(.system(size: 18))
                            .foregroundColor(categoryColor)
                    }
                }
                
                // Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(challenge.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(challenge.isCompleted ? .gray : .white)
                    
                    HStack(spacing: 8) {
                        // Difficulty badge
                        Text(challenge.difficulty.rawValue.capitalized)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(difficultyColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(difficultyColor.opacity(0.2))
                            .cornerRadius(4)
                        
                        // Rewards
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.yellow)
                            Text("+\(challenge.xpReward)")
                                .font(.system(size: 10))
                                .foregroundColor(.yellow)
                        }
                        
                        HStack(spacing: 2) {
                            Image(systemName: "gem.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.cyan)
                            Text("+\(challenge.gemReward)")
                                .font(.system(size: 10))
                                .foregroundColor(.cyan)
                        }
                    }
                }
                
                Spacer()
                
                // Arrow or check
                Image(systemName: challenge.isCompleted ? "checkmark.circle.fill" : "chevron.right")
                    .font(.system(size: 16))
                    .foregroundColor(challenge.isCompleted ? .green : .gray)
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(challenge.isCompleted ? Color.green.opacity(0.1) : Color.white.opacity(0.05))
            )
        }
        .disabled(challenge.isCompleted)
    }
    
    var categoryColor: Color {
        switch challenge.category {
        case .focus: return .blue
        case .memory: return .purple
        case .reaction: return .orange
        case .breathing: return .cyan
        case .discipline: return .red
        case .speed: return .yellow
        case .impulse: return .pink
        case .calm: return .teal
        }
    }
    
    var difficultyColor: Color {
        switch challenge.difficulty {
        case .easy: return .green
        case .medium: return .yellow
        case .hard: return .orange
        case .extreme: return .red
        }
    }
}

#Preview {
    HomeView().environmentObject(AppState())
}
