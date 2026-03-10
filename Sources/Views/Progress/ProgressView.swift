import SwiftUI

struct ProgressView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "0A0F1C"), Color(hex: "1E293B")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Level & XP Header
                    levelHeader
                    
                    // Skills Progress
                    skillsSection
                    
                    // Stats Grid
                    statsSection
                    
                    // Recent Activity
                    recentActivitySection
                }
                .padding()
            }
        }
    }
    
    var levelHeader: some View {
        VStack(spacing: 12) {
            // Level Circle
            ZStack {
                Circle()
                    .stroke(Color.purple.opacity(0.3), lineWidth: 8)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: xpProgress)
                    .stroke(
                        LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Text("\(appState.progress?.level ?? 1)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    Text("LEVEL")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.gray)
                }
            }
            
            // XP Progress
            VStack(spacing: 4) {
                Text("\(appState.progress?.totalXP ?? 0) XP")
                    .font(.headline)
                    .foregroundColor(.yellow)
                
                Text("\(xpToNextLevel - (appState.progress?.totalXP ?? 0)) XP to next level")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
    
    var skillsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Skills")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                SkillProgressBar(
                    title: "Focus",
                    icon: "brain.head.profile",
                    color: .purple,
                    score: appState.progress?.focusScore ?? 0,
                    maxScore: 100
                )
                
                SkillProgressBar(
                    title: "Impulse Control",
                    icon: "hand.raised.fill",
                    color: .orange,
                    score: appState.progress?.impulseControlScore ?? 0,
                    maxScore: 100
                )
                
                SkillProgressBar(
                    title: "Distraction Resistance",
                    icon: "eye.slash.fill",
                    color: .blue,
                    score: appState.progress?.distractionResistanceScore ?? 0,
                    maxScore: 100
                )
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
    
    var statsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Statistics")
                .font(.headline)
                .foregroundColor(.white)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatCard(title: "Streak", value: "\(appState.progress?.streakDays ?? 0)", icon: "flame.fill", color: .orange)
                StatCard(title: "Gems", value: "\(appState.progress?.gems ?? 0)", icon: "diamond.fill", color: .cyan)
                StatCard(title: "Hearts", value: "\(appState.progress?.hearts ?? 5)", icon: "heart.fill", color: .red)
                StatCard(title: "Badges", value: "\(appState.achievementStore.achievements.filter { $0.isUnlocked }.count)", icon: "trophy.fill", color: .yellow)
                StatCard(title: "Challenges", value: "\(appState.progress?.completedChallenges.count ?? 0)", icon: "checkmark.circle.fill", color: .green)
                StatCard(title: "Total XP", value: "\(appState.progress?.totalXP ?? 0)", icon: "star.fill", color: .purple)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
    
    var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.headline)
                .foregroundColor(.white)
            
            let recentChallenges = Array((appState.progress?.completedChallenges ?? []).suffix(5).reversed())
            
            if recentChallenges.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "clock.badge.questionmark")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    Text("No recent activity")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("Complete your first challenge to see it here!")
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                VStack(spacing: 8) {
                    ForEach(recentChallenges) { attempt in
                        ActivityRow(
                            title: attempt.challenge.rawValue,
                            subtitle: "\(formatDate(attempt.attemptedAt)) • +\(attempt.xpEarned) XP",
                            icon: attempt.challenge.icon,
                            color: categoryColor(for: attempt.challenge.category)
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
    
    func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter.string(from: date)
        }
    }
    
    func categoryColor(for category: ChallengeCategory) -> Color {
        switch category {
        case .focus: return .purple
        case .memory: return .blue
        case .reaction: return .orange
        case .breathing: return .cyan
        case .discipline: return .green
        case .speed: return .red
        case .impulse: return .pink
        case .calm: return .teal
        }
    }
    
    var xpProgress: CGFloat {
        let current = appState.progress?.totalXP ?? 0
        let needed = xpToNextLevel
        return min(CGFloat(current) / CGFloat(needed), 1.0)
    }
    
    var xpToNextLevel: Int {
        let level = appState.progress?.level ?? 1
        return level * 100
    }
}

struct SkillProgressBar: View {
    let title: String
    let icon: String
    let color: Color
    let score: Int
    let maxScore: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white)
                Spacer()
                Text("\(score)/\(maxScore)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(score) / CGFloat(maxScore), height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct ActivityRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.2))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.03))
        .cornerRadius(12)
    }
}

#Preview {
    ProgressView()
        .environmentObject(AppState())
}
