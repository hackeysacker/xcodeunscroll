import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @StateObject private var socialService = SocialService.shared
    @State private var selectedPeriod: LeaderboardPeriod = .weekly
    @State private var selectedCategory: LeaderboardCategory = .global
    @State private var showFriendChallenge: Bool = false
    @State private var selectedFriend: FriendProfile?
    @State private var challengeTitle: String = "7-Day Streak Challenge"
    
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
        .sheet(isPresented: $showFriendChallenge) {
            if let selectedFriend {
                FriendChallengeComposer(
                    friend: selectedFriend,
                    challengeTitle: $challengeTitle
                ) {
                    _ = socialService.challengeFriend(friendId: selectedFriend.id, challengeTitle: challengeTitle)
                }
            } else {
                friendPickerSheet
            }
        }
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
                if let onlineFriend = socialService.friends.first(where: { $0.isOnline }) {
                    selectedFriend = onlineFriend
                } else {
                    selectedFriend = socialService.friends.first
                }
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
                Text("#\(userRank)")
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
                LeaderboardRow(entry: entry, isCurrentUser: entry.isCurrentUser)
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Computed Properties
    var userRank: Int {
        leaderboardData.first(where: { $0.isCurrentUser })?.rank ?? 0
    }
    
    var rankColor: Color {
        if userRank <= 10 { return .yellow }
        if userRank <= 50 { return .green }
        if userRank <= 100 { return .blue }
        return .gray
    }
    
    var leaderboardData: [LeaderboardEntry] {
        let mode: LeaderboardMode = selectedCategory == .friends ? .friends : .global
        let currentName = appState.currentUser?.displayName ?? "You"
        let currentAvatar = appState.currentUser?.avatarEmoji ?? "🦞"
        let currentXP = appState.progress?.totalXP ?? 0
        let currentStreak = appState.progress?.streakDays ?? 0

        let data = socialService.leaderboardEntries(
            currentUserName: currentName,
            currentUserAvatar: currentAvatar,
            currentUserXP: currentXP,
            currentUserStreak: currentStreak,
            mode: mode
        )

        return data.enumerated().map { index, entry in
            LeaderboardEntry(
                rank: index + 1,
                name: entry.name,
                xp: entry.xp,
                streak: entry.streak,
                avatar: entry.avatar,
                isCurrentUser: entry.isCurrentUser
            )
        }
    }

    var friendPickerSheet: some View {
        ZStack {
            Color(hex: "0A0F1C").ignoresSafeArea()
            VStack(spacing: 12) {
                Text("Pick a Friend")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 20)

                ForEach(socialService.friends) { friend in
                    Button {
                        selectedFriend = friend
                    } label: {
                        HStack {
                            Text(friend.avatar)
                            Text(friend.name)
                                .foregroundColor(.white)
                            Spacer()
                            if selectedFriend?.id == friend.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.06)))
                    }
                }

                Button("Continue") {
                    if selectedFriend != nil {
                        showFriendChallenge = true
                    }
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Capsule().fill(Color.purple.opacity(0.4)))
                .padding(.top, 12)
                .disabled(selectedFriend == nil)
            }
            .padding(20)
        }
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
    let entry: LeaderboardEntry
    let rank: Int
    
    var body: some View {
        VStack(spacing: 8) {
            // Medal
            ZStack {
                Circle()
                    .fill(podiumColor.opacity(0.3))
                    .frame(width: rank == 1 ? 70 : 55, height: rank == 1 ? 70 : 55)
                
                Text(entry.avatar)
                    .font(.system(size: rank == 1 ? 32 : 26))
            }
            
            // Name
            Text(entry.name)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(1)
            
            // XP
            Text("\(entry.xp)")
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
    let entry: LeaderboardEntry
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
                    Text(entry.avatar)
                        .font(.system(size: 18))
                )
            
            // Name & streak
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.name)
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
                Text("\(entry.xp)")
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

// MARK: - Models
struct LeaderboardEntry: Identifiable {
    let id = UUID()
    let rank: Int
    let name: String
    let xp: Int
    let streak: Int
    let avatar: String
    let isCurrentUser: Bool
}

#Preview {
    LeaderboardView().environmentObject(AppState())
}
