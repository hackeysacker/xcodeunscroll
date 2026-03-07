import SwiftUI

// Type alias to use SupabaseService's LeaderboardEntryData
typealias LeaderboardEntryData = SupabaseService.LeaderboardEntryData

struct LeaderboardView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var selectedPeriod: LeaderboardPeriod = .weekly
    @State private var selectedCategory: LeaderboardCategory = .global
    @State private var showFriendChallenge: Bool = false
    
    // Real data from Supabase
    @State private var leaderboardData: [LeaderboardEntryData] = []
    @State private var userRank: Int = 0
    @State private var isLoading: Bool = true
    @State private var loadError: String?
    
    enum LeaderboardPeriod: String, CaseIterable {
        case daily = "Today"
        case weekly = "Week"
        case monthly = "Month"
        case allTime = "All Time"
    }
    
    enum LeaderboardCategory: String, CaseIterable {
        case global = "Global"
        case friends = "Friends"
        case regional = "Regional"
        case league = "League"
        
        var icon: String {
            switch self {
            case .global: return "globe"
            case .friends: return "person.2.fill"
            case .regional: return "map.fill"
            case .league: return "trophy.fill"
            }
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "0A0F1C"), Color(hex: "1E293B")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                header
                
                // Category selector
                categorySelector
                
                // Period selector
                periodSelector
                
                // League badge (if applicable)
                if selectedCategory == .league {
                    leagueBanner
                }
                
                // Main content
                if isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                        .scaleEffect(1.5)
                    Spacer()
                } else if let error = loadError {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "wifi.exclamationmark")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("Unable to load leaderboard")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            Task { await loadLeaderboard() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Your rank card
                            yourRankCard
                            
                            // Podium
                            podiumView
                            
                            // Leaderboard list
                            leaderboardList
                        }
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .task {
            await loadLeaderboard()
        }
    }
    
    func loadLeaderboard() async {
        isLoading = true
        loadError = nil
        
        do {
            // Fetch leaderboard data
            leaderboardData = try await SupabaseService.shared.fetchLeaderboard(limit: 50)
            
            // Fetch user's rank if logged in
            if let userId = appState.currentUser?.id {
                userRank = try await SupabaseService.shared.fetchUserRank(userId: userId)
            }
        } catch {
            loadError = error.localizedDescription
            // Fall back to mock data for demo purposes
            leaderboardData = Self.mockLeaderboardData
        }
        
        isLoading = false
    }
    
    // Mock data for fallback
    static var mockLeaderboardData: [LeaderboardEntryData] {
        [
            LeaderboardEntryData(userId: "1", displayName: "FocusMaster", avatarEmoji: "🦁", totalXp: 12500, level: 42, streak: 45, rank: 1),
            LeaderboardEntryData(userId: "2", displayName: "ZenWarrior", avatarEmoji: "🥷", totalXp: 11200, level: 38, streak: 38, rank: 2),
            LeaderboardEntryData(userId: "3", displayName: "ConcentrationKing", avatarEmoji: "👑", totalXp: 10800, level: 36, streak: 32, rank: 3),
            LeaderboardEntryData(userId: "4", displayName: "MindfulMike", avatarEmoji: "🧘", totalXp: 9500, level: 32, streak: 28, rank: 4),
            LeaderboardEntryData(userId: "5", displayName: "FlowFinder", avatarEmoji: "🌊", totalXp: 8900, level: 30, streak: 25, rank: 5),
            LeaderboardEntryData(userId: "6", displayName: "DeepWorker", avatarEmoji: "⚡", totalXp: 8200, level: 28, streak: 21, rank: 6),
            LeaderboardEntryData(userId: "7", displayName: "StillnessSeeker", avatarEmoji: "🕉️", totalXp: 7800, level: 26, streak: 19, rank: 7),
            LeaderboardEntryData(userId: "8", displayName: "PresentPaul", avatarEmoji: "🎯", totalXp: 7200, level: 24, streak: 16, rank: 8),
            LeaderboardEntryData(userId: "9", displayName: "CalmChris", avatarEmoji: "🧠", totalXp: 6800, level: 22, streak: 14, rank: 9),
            LeaderboardEntryData(userId: "10", displayName: "FocusedFred", avatarEmoji: "🎯", totalXp: 6500, level: 21, streak: 12, rank: 10),
        ]
    }
    
    var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark").font(.system(size: 18)).foregroundColor(.white).frame(width: 44, height: 44)
            }
            Spacer()
            Text("Leaderboard").font(.system(size: 20, weight: .bold)).foregroundColor(.white)
            Spacer()
            Button {
                showFriendChallenge.toggle()
            } label: {
                Image(systemName: "person.badge.plus").font(.system(size: 18)).foregroundColor(.purple)
            }
            .frame(width: 44, height: 44)
        }
        .padding(.top, 16)
    }
    
    var categorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(LeaderboardCategory.allCases, id: \.self) { category in
                    CategoryPill(
                        title: category.rawValue,
                        icon: category.icon,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 12)
    }
    
    var periodSelector: some View {
        HStack(spacing: 8) {
            ForEach(LeaderboardPeriod.allCases, id: \.self) { period in
                Button {
                    withAnimation {
                        selectedPeriod = period
                    }
                } label: {
                    Text(period.rawValue)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(selectedPeriod == period ? .white : .gray)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(selectedPeriod == period ? Color.purple.opacity(0.5) : Color.white.opacity(0.05))
                        )
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    var leagueBanner: some View {
        HStack {
            Image(systemName: "trophy.fill").foregroundColor(.yellow)
            Text("Diamond League")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            Spacer()
            Text("#4 of 25")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.yellow)
        }
        .padding()
        .background(
            LinearGradient(colors: [.purple.opacity(0.3), .indigo.opacity(0.3)], startPoint: .leading, endPoint: .trailing)
        )
        .cornerRadius(12)
        .padding(.horizontal, 16)
    }
    
    var yourRankCard: some View {
        HStack(spacing: 16) {
            // Rank
            VStack(spacing: 2) {
                Text("#\(userRank > 0 ? userRank : (appState.progress?.totalXP ?? 0) > 0 ? Int.random(in: 50...200) : 0)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(rankColor)
                Text("Your Rank")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
            .frame(width: 60)
            
            // Avatar
            Circle()
                .fill(LinearGradient(colors: [.purple, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 50, height: 50)
                .overlay(
                    Text("🦞")
                        .font(.system(size: 24))
                )
            
            // Stats
            VStack(alignment: .leading, spacing: 4) {
                Text(appState.currentUser?.displayName ?? "You")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                HStack(spacing: 12) {
                    Label("\(appState.progress?.totalXP ?? 0)", systemImage: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.yellow)
                    Label("Lv.\(appState.progress?.level ?? 1)", systemImage: "arrow.up.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.purple)
                }
            }
            
            Spacer()
            
            // Change indicator
            VStack(spacing: 2) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 12))
                    .foregroundColor(.green)
                Text("+\(Int.random(in: 1...5))")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .padding(.horizontal, 16)
    }
    
    var podiumView: some View {
        HStack(spacing: 0) {
            // 2nd place
            if leaderboardData.count > 1 {
                PodiumSpot(entry: leaderboardData[1], rank: 2)
            }
            
            // 1st place
            if !leaderboardData.isEmpty {
                PodiumSpot(entry: leaderboardData[0], rank: 1)
                    .offset(y: -20)
            }
            
            // 3rd place
            if leaderboardData.count > 2 {
                PodiumSpot(entry: leaderboardData[2], rank: 3)
            }
        }
        .padding(.horizontal, 16)
    }
    
    var leaderboardList: some View {
        VStack(spacing: 8) {
            ForEach(Array(leaderboardData.enumerated().dropFirst(3)), id: \.element.rank) { index, entry in
                LeaderboardRow(entry: entry, isCurrentUser: entry.userId == appState.currentUser?.id)
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Computed Properties
    var rankColor: Color {
        let rank = userRank > 0 ? userRank : 100
        if rank <= 10 { return .yellow }
        if rank <= 50 { return .green }
        if rank <= 100 { return .blue }
        return .gray
    }
}

// MARK: - Supporting Views
struct CategoryPill: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(title)
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : .gray)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.purple.opacity(0.5) : Color.white.opacity(0.05))
            )
        }
    }
}

struct PodiumSpot: View {
    let entry: LeaderboardEntryData
    let rank: Int
    
    var body: some View {
        VStack(spacing: 8) {
            // Medal
            ZStack {
                Circle()
                    .fill(podiumColor.opacity(0.3))
                    .frame(width: rank == 1 ? 70 : 55, height: rank == 1 ? 70 : 55)
                
                Text(entry.avatarEmoji ?? "🎯")
                    .font(.system(size: rank == 1 ? 32 : 26))
            }
            
            // Name
            Text(entry.displayName)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(1)
            
            // XP
            Text("\(entry.totalXp)")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.yellow)
            
            // Streak
            HStack(spacing: 2) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 10))
                Text("\(entry.streak)")
                    .font(.system(size: 10))
            }
            .foregroundColor(.orange)
        }
        .frame(maxWidth: .infinity)
    }
    
    var podiumColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .purple
        }
    }
}

struct LeaderboardRow: View {
    let entry: LeaderboardEntryData
    let isCurrentUser: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank
            Text("#\(entry.rank)")
                .font(.system(size: 14, weight: isCurrentUser ? .bold : .medium))
                .foregroundColor(isCurrentUser ? .purple : .gray)
                .frame(width: 35, alignment: .leading)
            
            // Avatar
            Circle()
                .fill(isCurrentUser ? LinearGradient(colors: [.purple, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(colors: [.gray, .gray.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(entry.avatarEmoji ?? "🎯")
                        .font(.system(size: 18))
                )
            
            // Name & streak
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.displayName)
                    .font(.system(size: 14, weight: isCurrentUser ? .semibold : .medium))
                    .foregroundColor(.white)
                
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 10))
                    Text("\(entry.streak) day streak")
                        .font(.system(size: 10))
                }
                .foregroundColor(.orange)
            }
            
            Spacer()
            
            // XP
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(entry.totalXp)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isCurrentUser ? .yellow : .white)
                Text("XP")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isCurrentUser ? Color.purple.opacity(0.15) : Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isCurrentUser ? Color.purple.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}

// MARK: - Models (Legacy - kept for reference)
struct LeaderboardEntry: Identifiable {
    let id = UUID()
    let rank: Int
    let name: String
    let xp: Int
    let streak: Int
    let avatar: String
}

#Preview {
    LeaderboardView().environmentObject(AppState())
}
