import SwiftUI

struct FocusHistoryView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedFilter: SessionFilter = .all
    
    enum SessionFilter: String, CaseIterable {
        case all = "All"
        case today = "Today"
        case thisWeek = "This Week"
        case completed = "Completed"
    }
    
    var filteredSessions: [FocusSession] {
        guard let sessions = appState.progress?.focusSessions else { return [] }
        
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedFilter {
        case .all:
            return sessions.sorted { $0.startTime > $1.startTime }
        case .today:
            return sessions.filter { calendar.isDateInToday($0.startTime) }
                .sorted { $0.startTime > $1.startTime }
        case .thisWeek:
            return sessions.filter {
                calendar.isDate($0.startTime, equalTo: now, toGranularity: .weekOfYear)
            }.sorted { $0.startTime > $1.startTime }
        case .completed:
            return sessions.filter { $0.wasCompleted }
                .sorted { $0.startTime > $1.startTime }
        }
    }
    
    var totalStats: (sessions: Int, minutes: Int, xp: Int) {
        let sessions = filteredSessions
        let totalMinutes = sessions.reduce(0) { $0 + $1.actualDurationMinutes }
        let totalXP = sessions.reduce(0) { $0 + $1.xpEarned }
        return (sessions.count, totalMinutes, totalXP)
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(hex: "0A0F1C"), Color(hex: "1E293B")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Stats Header
                statsHeader
                
                // Filter Pills
                filterPills
                
                // Sessions List
                if filteredSessions.isEmpty {
                    emptyState
                } else {
                    sessionsList
                }
            }
        }
        .navigationTitle("Focus History")
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Stats Header
    private var statsHeader: some View {
        HStack(spacing: 16) {
            FocusStatCard(
                icon: "timer",
                value: "\(totalStats.sessions)",
                label: "Sessions",
                color: .blue
            )
            
            FocusStatCard(
                icon: "clock.fill",
                value: "\(totalStats.minutes)",
                label: "Minutes",
                color: .green
            )
            
            FocusStatCard(
                icon: "star.fill",
                value: "\(totalStats.xp)",
                label: "XP",
                color: .yellow
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
    
    // MARK: - Filter Pills
    private var filterPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(SessionFilter.allCases, id: \.self) { filter in
                    FilterPill(
                        title: filter.rawValue,
                        isSelected: selectedFilter == filter
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedFilter = filter
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 12)
    }
    
    // MARK: - Sessions List
    private var sessionsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredSessions) { session in
                    SessionCard(session: session)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "timer.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No focus sessions yet")
                .font(.title2.bold())
                .foregroundColor(.white)
            
            Text("Complete your first focus session\nto see it here!")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
    }
}

// MARK: - Focus Stat Card
struct FocusStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Filter Pill
struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : .gray)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.purple : Color.white.opacity(0.1))
                .cornerRadius(20)
        }
    }
}

// MARK: - Session Card
struct SessionCard: View {
    let session: FocusSession
    
    var body: some View {
        HStack(spacing: 16) {
            // Status Icon
            ZStack {
                Circle()
                    .fill(session.wasCompleted ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: session.wasCompleted ? "checkmark.circle.fill" : "pause.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(session.wasCompleted ? .green : .orange)
            }
            
            // Session Info
            VStack(alignment: .leading, spacing: 4) {
                Text(formattedDate)
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack(spacing: 12) {
                    Label("\(session.actualDurationMinutes) min", systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if session.xpEarned > 0 {
                        Label("\(session.xpEarned) XP", systemImage: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                    
                    if session.gemsEarned > 0 {
                        Label("\(session.gemsEarned)", systemImage: "gem.fill")
                            .font(.caption)
                            .foregroundColor(.cyan)
                    }
                }
            }
            
            Spacer()
            
            // Completion Status
            Text(session.wasCompleted ? "✓" : "⏸")
                .font(.title2)
                .foregroundColor(session.wasCompleted ? .green : .orange)
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(session.startTime) {
            formatter.dateFormat = "'Today at' h:mm a"
        } else if calendar.isDateInYesterday(session.startTime) {
            formatter.dateFormat = "'Yesterday at' h:mm a"
        } else {
            formatter.dateFormat = "MMM d 'at' h:mm a"
        }
        
        return formatter.string(from: session.startTime)
    }
}

#Preview {
    NavigationStack {
        FocusHistoryView()
            .environmentObject(AppState())
    }
}
