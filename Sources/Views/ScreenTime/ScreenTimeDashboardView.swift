import SwiftUI
import ManagedSettings
import DeviceActivity
import FamilyControls

struct ScreenTimeDashboardView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var screenTime = ScreenTimeManager.shared
    @State private var selectedTab: Int = 0
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "0A0F1C"), Color(hex: "1E293B")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                header
                
                // Tab bar
                tabBar
                
                // Content
                ScrollView {
                    switch selectedTab {
                    case 0:
                        TodayView(screenTime: screenTime)
                    case 1:
                        ShieldView()
                    case 2:
                        RoutinesView()
                    case 3:
                        AppsView()
                    default:
                        TodayView(screenTime: screenTime)
                    }
                }
            }
        }
        .onAppear {
            screenTime.checkAuthorization()
        }
    }
    
    var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Focus")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                Text("Screen Time & Protection")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            Spacer()
            Button(action: { requestAccess() }) {
                VStack(spacing: 4) {
                    Image(systemName: screenTime.isAuthorized ? "checkmark.shield.fill" : "shield.fill")
                        .font(.system(size: 24))
                        .foregroundColor(screenTime.isAuthorized ? .green : .orange)
                    Text(screenTime.isAuthorized ? "Active" : "Setup")
                        .font(.system(size: 10))
                        .foregroundColor(screenTime.isAuthorized ? .green : .orange)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 12)
    }
    
    var tabBar: some View {
        HStack(spacing: 0) {
            TabButton(icon: "chart.bar.fill", title: "Today", isSelected: selectedTab == 0) { selectedTab = 0 }
            TabButton(icon: "shield.fill", title: "Shield", isSelected: selectedTab == 1) { selectedTab = 1 }
            TabButton(icon: "clock.badge.checkmark.fill", title: "Routines", isSelected: selectedTab == 2) { selectedTab = 2 }
            TabButton(icon: "app.badge.fill", title: "Apps", isSelected: selectedTab == 3) { selectedTab = 3 }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
    
    func requestAccess() {
        screenTime.requestAuthorization()
    }
}

struct TabButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                Text(title)
                    .font(.system(size: 10))
            }
            .foregroundColor(isSelected ? .purple : .gray)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.purple.opacity(0.2) : Color.clear)
            )
        }
    }
}

// MARK: - Today View (Enhanced)
struct TodayView: View {
    @ObservedObject var screenTime: ScreenTimeManager
    @State private var dailyGoal: Int = 120
    
    var body: some View {
        VStack(spacing: 20) {
            // Main ring
            mainRing
            
            // Quick stats
            quickStats
            
            // Usage by category
            categoriesSection
            
            // Top apps
            topAppsSection
            
            // Focus schedule
            focusScheduleSection
        }
        .padding(.vertical)
    }
    
    var mainRing: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 20)
                .frame(width: 200, height: 200)
            
            let progress = min(1.0, Double(screenTime.todayMinutes) / Double(dailyGoal))
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(colors: [.purple, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing),
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
                .animation(.spring(), value: progress)
            
            VStack(spacing: 4) {
                Text("\(screenTime.todayMinutes)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                Text("of \(dailyGoal) min")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
        }
        .padding(.top, 12)
    }
    
    var quickStats: some View {
        HStack(spacing: 12) {
            StatBox(icon: "flame.fill", value: "\(screenTime.pickupCount)", label: "Pickups", color: .orange)
            StatBox(icon: "bell.badge.fill", value: "\(screenTime.notificationsCount)", label: "Alerts", color: .red)
            StatBox(icon: "clock.fill", value: "\(screenTime.weeklyMinutes / 60)h", label: "Week", color: .cyan)
        }
        .padding(.horizontal)
    }
    
    var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Screen Time")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Text("Today")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            ForEach(screenTime.categories) { cat in
                CategoryRow(category: cat, total: screenTime.todayMinutes)
            }
            
            if screenTime.categories.isEmpty {
                Text("No data available")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    var topAppsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Apps")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(spacing: 8) {
                ForEach(0..<5, id: \.self) { index in
                    AppUsageRow(rank: index + 1, name: topApps[index].0, minutes: topApps[index].1, color: topApps[index].2)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    var topApps: [(String, Int, Color)] {
        [
            ("Instagram", 45, .pink),
            ("TikTok", 38, .black),
            ("YouTube", 30, .red),
            ("Twitter", 22, .blue),
            ("Reddit", 15, .orange)
        ]
    }
    
    var focusScheduleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Focus")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                FocusScheduleCard(title: "Morning", time: "8AM-12PM", isActive: false, color: .yellow)
                FocusScheduleCard(title: "Afternoon", time: "12PM-5PM", isActive: true, color: .green)
                FocusScheduleCard(title: "Evening", time: "5PM-10PM", isActive: false, color: .purple)
            }
        }
        .padding(.horizontal)
    }
}

struct StatBox: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 18)).foregroundColor(color)
            Text(value).font(.system(size: 20, weight: .bold)).foregroundColor(.white)
            Text(label).font(.system(size: 10)).foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct CategoryRow: View {
    let category: ScreenTimeCategory
    let total: Int
    
    var body: some View {
        let percentage = total > 0 ? Double(category.minutes) / Double(total) : 0
        
        VStack(spacing: 6) {
            HStack {
                Circle()
                    .fill(category.color)
                    .frame(width: 10, height: 10)
                
                Text(category.name)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(category.minutes) min")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.1))
                    
                    RoundedRectangle(cornerRadius: 3)
                        .fill(category.color)
                        .frame(width: geo.size.width * percentage)
                }
            }
            .frame(height: 6)
        }
    }
}

struct AppUsageRow: View {
    let rank: Int
    let name: String
    let minutes: Int
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Text("#\(rank)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(rank == 1 ? .yellow : .gray)
                .frame(width: 24)
            
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(name)
                .font(.system(size: 14))
                .foregroundColor(.white)
            
            Spacer()
            
            Text("\(minutes)m")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

struct FocusScheduleCard: View {
    let title: String
    let time: String
    let isActive: Bool
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Circle()
                .fill(isActive ? color : Color.white.opacity(0.1))
                .frame(width: 12, height: 12)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isActive ? .white : .gray)
            
            Text(time)
                .font(.system(size: 10))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isActive ? color.opacity(0.15) : Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isActive ? color.opacity(0.5) : Color.clear, lineWidth: 1)
        )
    }
}

// MARK: - Shield View (Enhanced)
struct ShieldView: View {
    @State private var selectedMode: FocusMode = .off
    @State private var showAppPicker: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Shield status
            shieldStatus
            
            // Mode buttons
            modeSelector
            
            // Blocked apps summary
            blockedAppsSection
            
            // Custom shield button
            customShieldButton
        }
        .padding(.vertical)
    }
    
    var shieldStatus: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(selectedMode == .off ? Color.white.opacity(0.1) : selectedMode.color.opacity(0.2))
                    .frame(width: 150, height: 150)
                
                Circle()
                    .stroke(selectedMode.color.opacity(0.5), lineWidth: 4)
                    .frame(width: 150, height: 150)
                
                Image(systemName: selectedMode == .off ? "shield.slash" : "shield.checkered")
                    .font(.system(size: 60))
                    .foregroundColor(selectedMode == .off ? .gray : selectedMode.color)
            }
            
            Text(selectedMode == .off ? "Shield Off" : "\(selectedMode.rawValue) Active")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            if selectedMode != .off {
                Text("\(ScreenTimeManager.shared.blockedApps.count) apps blocked")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
        }
        .padding(.top, 12)
    }
    
    var modeSelector: some View {
        VStack(spacing: 10) {
            ForEach(FocusMode.allCases.filter { $0 != .custom }, id: \.self) { mode in
                ModeButton(mode: mode, isSelected: selectedMode == mode) {
                    withAnimation {
                        selectedMode = selectedMode == mode ? .off : mode
                        if selectedMode != .off {
                            ScreenTimeManager.shared.activateFocusMode(mode)
                        } else {
                            ScreenTimeManager.shared.disableShield()
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    var blockedAppsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Blocked Apps")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Button("Manage") {
                    showAppPicker = true
                }
                .font(.system(size: 14))
                .foregroundColor(.purple)
            }
            
            if ScreenTimeManager.shared.blockedApps.isEmpty {
                Text("No apps selected. Tap 'Select Apps' to choose.")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(ScreenTimeManager.shared.blockedApps).prefix(5), id: \.self) { app in
                            Text(app)
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
            }
            
            Button {
                showAppPicker = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Select Apps")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.purple)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .padding(.horizontal)
        .sheet(isPresented: $showAppPicker) {
            AppPickerView(isPresented: $showAppPicker)
        }
    }
    
    var customShieldButton: some View {
        Button {
            // Custom shield configuration
        } label: {
            HStack {
                Image(systemName: "slider.horizontal.3")
                Text("Custom Shield Settings")
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

struct ModeButton: View {
    let mode: FocusMode
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: mode.icon)
                    .font(.system(size: 20))
                    .foregroundColor(mode.color)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(mode.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    Text(mode.description)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(mode.color)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? mode.color.opacity(0.15) : Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? mode.color.opacity(0.5) : Color.clear, lineWidth: 1)
            )
        }
    }
}

// MARK: - Routines View
struct RoutinesView: View {
    @State private var showAddRoutine: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Focus Routines")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Button {
                    showAddRoutine = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.purple)
                }
            }
            .padding(.horizontal)
            
            // Active routines
            VStack(spacing: 12) {
                RoutineCard(
                    name: "Morning Focus",
                    schedule: "8:00 AM - 12:00 PM",
                    days: "Mon-Fri",
                    isActive: true,
                    mode: .work
                )
                
                RoutineCard(
                    name: "Evening Wind Down",
                    schedule: "9:00 PM - 10:00 PM",
                    days: "Every Day",
                    isActive: true,
                    mode: .evening
                )
                
                RoutineCard(
                    name: "Weekend Relax",
                    schedule: "10:00 AM - 2:00 PM",
                    days: "Sat-Sun",
                    isActive: false,
                    mode: .personal
                )
            }
            .padding(.horizontal)
            
            // Quick actions
            VStack(alignment: .leading, spacing: 12) {
                Text("Quick Actions")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                HStack(spacing: 12) {
                    RoutineQuickAction(icon: "cup.and.saucer.fill", title: "Take a Break", color: .blue) { }
                    RoutineQuickAction(icon: "moon.fill", title: "Sleep Mode", color: .indigo) { }
                    RoutineQuickAction(icon: "figure.walk", title: "Move", color: .green) { }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top)
    }
}

struct RoutineCard: View {
    let name: String
    let schedule: String
    let days: String
    let isActive: Bool
    let mode: FocusMode
    
    @State private var isEnabled: Bool = false
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Circle()
                    .fill(mode.color)
                    .frame(width: 12, height: 12)
                
                Text(name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Toggle("", isOn: $isEnabled)
                    .tint(.purple)
            }
            
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "clock").font(.system(size: 12)).foregroundColor(.gray)
                    Text(schedule).font(.system(size: 14)).foregroundColor(.gray)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "calendar").font(.system(size: 12)).foregroundColor(.gray)
                    Text(days).font(.system(size: 14)).foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isActive ? mode.color.opacity(0.3) : Color.clear, lineWidth: 1)
        )
        .onAppear {
            isEnabled = isActive
        }
    }
}

struct RoutineQuickAction: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(color.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

// MARK: - Apps View
struct AppsView: View {
    @State private var showAppPicker: Bool = false
    @State private var selectedCategory: AppCategory = .social
    
    enum AppCategory: String, CaseIterable {
        case social = "Social"
        case entertainment = "Entertainment"
        case games = "Games"
        case productivity = "Productivity"
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Category selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(AppCategory.allCases, id: \.self) { cat in
                        Button {
                            selectedCategory = cat
                        } label: {
                            Text(cat.rawValue)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(selectedCategory == cat ? .white : .gray)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(selectedCategory == cat ? Color.purple.opacity(0.5) : Color.white.opacity(0.1))
                                )
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Apps list
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(Array(appsForCategory(selectedCategory).enumerated()), id: \.offset) { _, app in
                        AppRow(name: app.0, icon: app.1, isBlocked: ScreenTimeManager.shared.blockedApps.contains(app.0))
                    }
                }
                .padding(.horizontal)
            }
            
            // Add app button
            Button {
                showAppPicker = true
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Add App to Block")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing))
                .cornerRadius(14)
            }
            .padding(.horizontal)
        }
        .sheet(isPresented: $showAppPicker) {
            AppPickerView(isPresented: $showAppPicker)
        }
    }
    
    func appsForCategory(_ category: AppCategory) -> [(String, String)] {
        switch category {
        case .social:
            return [("Instagram", "camera.fill"), ("TikTok", "play.rectangle.fill"), ("Twitter", "bubble.left.fill"), ("Facebook", "person.2.fill"), ("Snapchat", "bolt.fill")]
        case .entertainment:
            return [("YouTube", "play.rectangle.fill"), ("Netflix", "tv.fill"), ("Spotify", "music.note"), ("Twitch", "gamecontroller.fill")]
        case .games:
            return [("Candy Crush", "gamecontroller.fill"), ("PUBG Mobile", "gamecontroller.fill"), ("Genshin Impact", "star.fill")]
        case .productivity:
            return [("Slack", "message.fill"), ("Email", "envelope.fill"), ("Teams", "person.3.fill")]
        }
    }
}

struct AppRow: View {
    let name: String
    let icon: String
    let isBlocked: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.purple)
                .frame(width: 40, height: 40)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(10)
            
            Text(name)
                .font(.system(size: 16))
                .foregroundColor(.white)
            
            Spacer()
            
            Text(isBlocked ? "Blocked" : "Allowed")
                .font(.system(size: 12))
                .foregroundColor(isBlocked ? .red : .green)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(isBlocked ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
                )
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - App Picker View
struct AppPickerView: View {
    @Binding var isPresented: Bool
    @State private var selection = FamilyActivitySelection()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0A0F1C").ignoresSafeArea()
                
                VStack {
                    if #available(iOS 16.0, *) {
                        FamilyActivityPicker(selection: $selection)
                            .onChange(of: selection) { _, newValue in
                                saveSelection(newValue)
                            }
                    } else {
                        Text("App selection requires iOS 16+")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Select Apps")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.gray)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                    .foregroundColor(.purple)
                }
            }
        }
    }
    
    func saveSelection(_ selection: FamilyActivitySelection) {
        // Save selected apps to ScreenTimeManager
        var selectedApps = Set<String>()
        // Note: In production, you'd iterate through selection.applicationTokens
        ScreenTimeManager.shared.blockedApps = selectedApps
    }
}

#Preview {
    ScreenTimeDashboardView().environmentObject(AppState())
}
