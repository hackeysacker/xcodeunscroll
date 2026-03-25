import SwiftUI
import Charts

struct InsightsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedTimeRange: TimeRange = .week
    @State private var selectedCategory: ChallengeCategory?
    
    enum TimeRange: String, CaseIterable {
        case week = "7 Days"
        case month = "30 Days"
        case allTime = "All Time"
    }
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "0A0F1C"), Color(hex: "1E293B")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    header
                    
                    // Time range selector
                    timeRangeSelector
                    
                    // Summary cards
                    summaryCards
                    
                    // Activity chart
                    activityChart
                    
                    // Category breakdown
                    categoryBreakdown
                    
                    // Skill progress
                    skillProgress
                    
                    // Streak & consistency
                    streakSection
                    
                    // Top challenges
                    topChallengesSection
                    
                    // Predictions
                    predictionsSection
                }
                .padding(.bottom, 100)
            }
        }
    }
    
    // MARK: - Header
    var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark").font(.system(size: 18)).foregroundColor(.white).frame(width: 44, height: 44)
            }
            Spacer()
            Text("Insights").font(.system(size: 20, weight: .bold)).foregroundColor(.white)
            Spacer()
            Button {
                // Export data
            } label: {
                Image(systemName: "square.and.arrow.up").font(.system(size: 18)).foregroundColor(.white)
            }
            .frame(width: 44, height: 44)
        }
        .padding(.top, 16)
    }
    
    // MARK: - Time Range Selector
    var timeRangeSelector: some View {
        HStack(spacing: 8) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTimeRange = range
                    }
                } label: {
                    Text(range.rawValue)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(selectedTimeRange == range ? .white : .gray)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(selectedTimeRange == range ? Color.purple.opacity(0.5) : Color.white.opacity(0.05))
                        )
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Summary Cards
    var summaryCards: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            InsightStatCard(
                title: "Total XP",
                value: "\(filteredProgress.totalXP)",
                icon: "star.fill",
                color: .yellow,
                trend: calculateTrend(current: filteredProgress.totalXP, previous: filteredProgress.totalXP / 2)
            )
            
            InsightStatCard(
                title: "Challenges",
                value: "\(filteredProgress.completedCount)",
                icon: "checkmark.circle.fill",
                color: .green,
                trend: calculateTrend(current: filteredProgress.completedCount, previous: filteredProgress.completedCount / 2)
            )
            
            InsightStatCard(
                title: "Best Score",
                value: "\(filteredProgress.bestScore)%",
                icon: "trophy.fill",
                color: .orange,
                trend: nil
            )
            
            InsightStatCard(
                title: "Avg. Score",
                value: "\(filteredProgress.averageScore)%",
                icon: "chart.bar.fill",
                color: .blue,
                trend: calculateTrend(current: filteredProgress.averageScore, previous: filteredProgress.averageScore - 10)
            )
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Activity Chart
    var activityChart: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Activity")
                        .font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                    Spacer()
                    Text(periodLabel)
                        .font(.system(size: 12)).foregroundColor(.gray)
                }
                
                Chart(filteredActivityData) { item in
                    BarMark(
                        x: .value("Day", item.day),
                        y: .value("XP", item.xp)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .indigo],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .cornerRadius(4)
                }
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisValueLabel()
                            .foregroundStyle(Color.gray)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisGridLine()
                            .foregroundStyle(Color.white.opacity(0.1))
                        AxisValueLabel()
                            .foregroundStyle(Color.gray)
                    }
                }
                .frame(height: 180)
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Category Breakdown
    var categoryBreakdown: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("By Category")
                .font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                .padding(.horizontal, 16)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(ChallengeCategory.allCases, id: \.self) { category in
                    CategoryCard(
                        category: category,
                        count: categoryCount(for: category),
                        percentage: categoryPercentage(for: category)
                    )
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Skill Progress
    var skillProgress: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Skill Levels")
                .font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                .padding(.horizontal, 16)
            
            VStack(spacing: 12) {
                ForEach(skillData) { skill in
                    SkillProgressRow(skill: skill)
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Streak Section
    var streakSection: some View {
        HStack(spacing: 16) {
            GlassCard {
                VStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.orange)
                    Text("\(appState.progress?.streakDays ?? 0)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    Text("Day Streak")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
            }
            
            GlassCard {
                VStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.system(size: 30))
                        .foregroundColor(.blue)
                    Text("\(appState.progress?.completedChallenges.count ?? 0)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    Text("Total Sessions")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
            }
            
            GlassCard {
                VStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.purple)
                    Text("\(totalMinutes)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    Text("Minutes")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Top Challenges
    var topChallengesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Top Challenges")
                .font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                .padding(.horizontal, 16)
            
            if let challenges = appState.progress?.completedChallenges, !challenges.isEmpty {
                let top = challenges.sorted { $0.score > $1.score }.prefix(5)
                VStack(spacing: 8) {
                    ForEach(Array(top.enumerated()), id: \.element.id) { index, challenge in
                        TopChallengeRow(rank: index + 1, attempt: challenge)
                    }
                }
                .padding(.horizontal, 16)
            } else {
                GlassCard {
                    VStack(spacing: 12) {
                        Image(systemName: "chart.bar.xaxis")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("Complete challenges to see your top performances!")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    // MARK: - Predictions
    var predictionsSection: some View {
        GlassCard(tint: .blue) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "crystalball.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                    Text("Predictions")
                        .font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                }
                
                VStack(spacing: 12) {
                    PredictionRow(
                        icon: "level.up",
                        title: "Next Level",
                        prediction: nextLevelPrediction
                    )
                    
                    PredictionRow(
                        icon: "calendar.badge.clock",
                        title: "Daily Goal",
                        prediction: dailyGoalPrediction
                    )
                    
                    PredictionRow(
                        icon: "star",
                        title: "Weekly XP",
                        prediction: weeklyXPPrediction
                    )
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Computed Properties
    var periodLabel: String {
        switch selectedTimeRange {
        case .week: return "Last 7 days"
        case .month: return "Last 30 days"
        case .allTime: return "All time"
        }
    }
    
    var filteredProgress: FilteredProgress {
        let completed = appState.progress?.completedChallenges ?? []
        let totalXP = completed.reduce(0) { $0 + $1.xpEarned }
        let bestScore = completed.map { $0.score }.max() ?? 0
        let avgScore = completed.isEmpty ? 0 : completed.reduce(0) { $0 + $1.score } / completed.count
        
        return FilteredProgress(
            totalXP: totalXP,
            completedCount: completed.count,
            bestScore: bestScore,
            averageScore: avgScore
        )
    }
    
    var filteredActivityData: [ActivityData] {
        switch selectedTimeRange {
        case .week:
            return [ActivityData(day: "M", xp: 45), ActivityData(day: "T", xp: 30), ActivityData(day: "W", xp: 60), ActivityData(day: "T", xp: 20), ActivityData(day: "F", xp: 55), ActivityData(day: "S", xp: 40), ActivityData(day: "S", xp: 35)]
        case .month:
            return (0..<4).flatMap { week in
                ["M", "T", "W", "T", "F", "S", "S"].enumerated().map { day, name in
                    ActivityData(day: "\(name)", xp: Int.random(in: 20...80))
                }
            }
        case .allTime:
            return [ActivityData(day: "Jan", xp: 300), ActivityData(day: "Feb", xp: 450), ActivityData(day: "Mar", xp: 380), ActivityData(day: "Apr", xp: 520)]
        }
    }
    
    var skillData: [SkillData] {
        let skills = appState.progress?.skills ?? [:]
        return [
            SkillData(name: "Focus", level: skills["focus"] ?? 1, color: .purple, icon: "target"),
            SkillData(name: "Memory", level: skills["memory"] ?? 1, color: .blue, icon: "brain.head.profile"),
            SkillData(name: "Discipline", level: skills["discipline"] ?? 1, color: .green, icon: "hand.raised.fill"),
            SkillData(name: "Reaction", level: skills["reaction"] ?? 1, color: .orange, icon: "bolt.fill"),
            SkillData(name: "Breathing", level: skills["breathing"] ?? 1, color: .cyan, icon: "wind")
        ]
    }
    
    var totalMinutes: Int {
        let challenges = appState.progress?.completedChallenges ?? []
        return challenges.reduce(0) { $0 + Int($1.duration) } / 60
    }
    
    func categoryCount(for category: ChallengeCategory) -> Int {
        let challenges = appState.progress?.completedChallenges ?? []
        return challenges.filter { AllChallengeType(rawValue: $0.challengeTypeRaw)?.category == category }.count
    }
    
    func categoryPercentage(for category: ChallengeCategory) -> Double {
        let total = appState.progress?.completedChallenges.count ?? 1
        let count = categoryCount(for: category)
        guard total > 0 else { return 0 }
        return Double(count) / Double(total) * 100
    }
    
    func calculateTrend(current: Int, previous: Int) -> Double? {
        guard previous > 0 else { return nil }
        return Double(current - previous) / Double(previous) * 100
    }
    
    var nextLevelPrediction: String {
        let currentXP = appState.progress?.totalXP ?? 0
        let xpToNextLevel = 1000 - (currentXP % 1000)
        if xpToNextLevel <= 0 {
            return "Level up imminent!"
        }
        let avgXPPerDay = 50
        let days = xpToNextLevel / avgXPPerDay
        return "\(days) days (\(xpToNextLevel) XP)"
    }
    
    var dailyGoalPrediction: String {
        return "On track - 60% complete"
    }
    
    var weeklyXPPrediction: String {
        return "~350 XP this week"
    }
}

// MARK: - Supporting Types
struct FilteredProgress {
    let totalXP: Int
    let completedCount: Int
    let bestScore: Int
    let averageScore: Int
}

struct ActivityData: Identifiable {
    let id = UUID()
    let day: String
    let xp: Int
}

struct SkillData: Identifiable {
    let id = UUID()
    let name: String
    let level: Int
    let color: Color
    let icon: String
}

// MARK: - Insight Stat Card
struct InsightStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let trend: Double?
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: icon).font(.system(size: 16)).foregroundColor(color)
                    Spacer()
                    if let trend = trend {
                        HStack(spacing: 2) {
                            Image(systemName: trend >= 0 ? "arrow.up.right" : "arrow.down.right")
                            Text("\(Int(abs(trend)))%")
                        }
                        .font(.system(size: 10))
                        .foregroundColor(trend >= 0 ? .green : .red)
                    }
                }
                
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - Category Card
struct CategoryCard: View {
    let category: ChallengeCategory
    let count: Int
    let percentage: Double
    
    var body: some View {
        GlassCard(cornerRadius: 12) {
            HStack {
                Image(systemName: category.icon)
                    .font(.system(size: 20))
                    .foregroundColor(category.color)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(category.rawValue)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                    Text("\(count) challenges")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("\(Int(percentage))%")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(category.color)
            }
        }
    }
}

// MARK: - Skill Progress Row
struct SkillProgressRow: View {
    let skill: SkillData
    
    var body: some View {
        GlassCard(cornerRadius: 12) {
            HStack {
                Image(systemName: skill.icon)
                    .font(.system(size: 20))
                    .foregroundColor(skill.color)
                    .frame(width: 30)
                
                Text(skill.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 80, alignment: .leading)
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.1))
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(skill.color)
                            .frame(width: geo.size.width * min(Double(skill.level) / 5.0, 1.0))
                    }
                }
                .frame(height: 8)
                
                Text("Lv.\(skill.level)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(skill.color)
                    .frame(width: 40, alignment: .trailing)
            }
        }
    }
}

// MARK: - Top Challenge Row
struct TopChallengeRow: View {
    let rank: Int
    let attempt: ChallengeAttempt
    
    var body: some View {
        GlassCard(cornerRadius: 12) {
            HStack {
                Text("#\(rank)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(rank == 1 ? .yellow : (rank == 2 ? .gray : .orange))
                    .frame(width: 30)
                
                Text(attempt.challengeTypeRaw)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(attempt.score)%")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(attempt.score >= 90 ? .green : (attempt.score >= 70 ? .yellow : .orange))
                    
                    Text("+\(attempt.xpEarned) XP")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

// MARK: - Prediction Row
struct PredictionRow: View {
    let icon: String
    let title: String
    let prediction: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.white)
            
            Spacer()
            
            Text(prediction)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Challenge Category Color Extension
extension ChallengeCategory {
    var color: Color {
        switch self {
        case .focus: return .purple
        case .memory: return .blue
        case .reaction: return .orange
        case .breathing: return .cyan
        case .discipline: return .green
        case .speed: return .yellow
        case .impulse: return .pink
        case .calm: return .teal
        }
    }
}

#Preview {
    InsightsView().environmentObject(AppState())
}
