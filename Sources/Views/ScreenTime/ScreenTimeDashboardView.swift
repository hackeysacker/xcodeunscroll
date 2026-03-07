import SwiftUI
import ManagedSettings
import DeviceActivity
import FamilyControls

// Type alias for backward compatibility
typealias FocusRoutine = DashboardFocusRoutine

// MARK: - Custom Routine Model
struct DashboardFocusRoutine: Identifiable, Codable {
    var id: String = UUID().uuidString
    var name: String
    var emoji: String
    var steps: [RoutineStep]
    var isEnabled: Bool = false
    var totalMinutes: Int { steps.reduce(0) { $0 + $1.minutes } }
}

struct RoutineStep: Identifiable, Codable {
    var id: String = UUID().uuidString
    var label: String
    var minutes: Int
    var icon: String
}

// MARK: - Shield Reward Model
struct ShieldReward: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let xpReward: Int
    let gemReward: Int
    let requirement: String
    var earned: Bool = false
}

// MARK: - Blocked App Model
struct BlockedApp: Identifiable, Codable {
    var id: String = UUID().uuidString
    var name: String
    var icon: String
    var category: String
    var isBlocked: Bool = true
}

// MARK: - App State Extensions
extension AppState {
    var savedRoutines: [FocusRoutine] {
        guard let data = UserDefaults.standard.data(forKey: "focus_routines"),
              let decoded = try? JSONDecoder().decode([FocusRoutine].self, from: data)
        else { return FocusRoutine.defaults }
        return decoded
    }

    func saveRoutines(_ routines: [FocusRoutine]) {
        if let data = try? JSONEncoder().encode(routines) {
            UserDefaults.standard.set(data, forKey: "focus_routines")
        }
    }

    var savedBlockedApps: [BlockedApp] {
        guard let data = UserDefaults.standard.data(forKey: "blocked_apps"),
              let decoded = try? JSONDecoder().decode([BlockedApp].self, from: data)
        else { return BlockedApp.defaults }
        return decoded
    }

    func saveBlockedApps(_ apps: [BlockedApp]) {
        if let data = try? JSONEncoder().encode(apps) {
            UserDefaults.standard.set(data, forKey: "blocked_apps")
        }
    }
}

extension FocusRoutine {
    static var defaults: [FocusRoutine] {[
        FocusRoutine(name: "Morning Focus", emoji: "☀️", steps: [
            RoutineStep(label: "Breathe & Center", minutes: 5,  icon: "wind"),
            RoutineStep(label: "Deep Work",        minutes: 90, icon: "brain.head.profile"),
            RoutineStep(label: "Short Break",      minutes: 10, icon: "cup.and.saucer.fill"),
        ]),
        FocusRoutine(name: "Evening Wind Down", emoji: "🌙", steps: [
            RoutineStep(label: "Review & Reflect", minutes: 10, icon: "doc.text.fill"),
            RoutineStep(label: "Light Reading",    minutes: 20, icon: "book.fill"),
            RoutineStep(label: "Meditation",       minutes: 10, icon: "sparkles"),
        ]),
    ]}
}

extension BlockedApp {
    static var defaults: [BlockedApp] {[
        BlockedApp(name: "Instagram",   icon: "camera.fill",                       category: "Social"),
        BlockedApp(name: "TikTok",      icon: "play.rectangle.fill",               category: "Social"),
        BlockedApp(name: "Twitter / X", icon: "bird.fill",                         category: "Social"),
        BlockedApp(name: "YouTube",     icon: "play.circle.fill",                  category: "Entertainment"),
        BlockedApp(name: "Facebook",    icon: "person.2.fill",                     category: "Social"),
        BlockedApp(name: "Snapchat",    icon: "bolt.fill",                         category: "Social"),
        BlockedApp(name: "Reddit",      icon: "bubble.left.and.bubble.right.fill", category: "Social"),
        BlockedApp(name: "Netflix",     icon: "tv.fill",                           category: "Entertainment"),
        BlockedApp(name: "Discord",     icon: "message.fill",                      category: "Social"),
        BlockedApp(name: "Twitch",      icon: "gamecontroller.fill",               category: "Entertainment"),
    ]}
}

// MARK: - Main Dashboard
struct ScreenTimeDashboardView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var screenTime = ScreenTimeManager.shared
    @State private var selectedTab: Int = 0

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "06060F"), Color(hex: "0A0F1C")],
                           startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack(spacing: 0) {
                header
                tabBar
                ScrollView(showsIndicators: false) {
                    Group {
                        switch selectedTab {
                        case 0:  TodayView(screenTime: screenTime)
                        case 1:  GamifiedShieldView()
                        case 2:  CustomRoutinesView()
                        case 3:  AppBlockingView()
                        default: TodayView(screenTime: screenTime)
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
        }
        .onAppear { screenTime.checkAuthorization() }
    }

    var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("FOCUS")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundColor(.white.opacity(0.35)).tracking(2)
                Text("Shield & Routines")
                    .font(.system(size: 24, weight: .bold)).foregroundColor(.white)
            }
            Spacer()
            Button(action: { screenTime.requestAuthorization() }) {
                HStack(spacing: 5) {
                    Image(systemName: screenTime.isAuthorized ? "checkmark.shield.fill" : "shield.slash.fill")
                        .font(.system(size: 15))
                        .foregroundColor(screenTime.isAuthorized ? .green : .orange)
                    Text(screenTime.isAuthorized ? "Active" : "Setup")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(screenTime.isAuthorized ? .green : .orange)
                }
                .padding(.horizontal, 12).padding(.vertical, 7)
                .background(Capsule().fill(Color.white.opacity(0.06)).overlay(Capsule().stroke(Color.white.opacity(0.1), lineWidth: 1)))
            }
        }
        .padding(.horizontal, 20).padding(.top, 60).padding(.bottom, 12)
    }

    var tabBar: some View {
        HStack(spacing: 0) {
            FocusTabButton(icon: "chart.bar.fill",             title: "Today",    isSelected: selectedTab == 0) { selectedTab = 0 }
            FocusTabButton(icon: "shield.checkered",           title: "Shield",   isSelected: selectedTab == 1) { selectedTab = 1 }
            FocusTabButton(icon: "clock.badge.checkmark.fill", title: "Routines", isSelected: selectedTab == 2) { selectedTab = 2 }
            FocusTabButton(icon: "app.badge.fill",             title: "Apps",     isSelected: selectedTab == 3) { selectedTab = 3 }
        }
        .padding(.horizontal, 16).padding(.bottom, 4)
    }
}

struct FocusTabButton: View {
    let icon: String; let title: String; let isSelected: Bool; let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 16))
                Text(title).font(.system(size: 10, weight: .semibold))
            }
            .foregroundColor(isSelected ? .purple : .gray)
            .frame(maxWidth: .infinity).padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 10).fill(isSelected ? Color.purple.opacity(0.15) : Color.clear))
        }
    }
}

// MARK: - Today View
struct TodayView: View {
    @ObservedObject var screenTime: ScreenTimeManager
    @State private var dailyGoal: Int = 120
    var body: some View {
        VStack(spacing: 20) {
            mainRing
            quickStats
            categoriesSection
        }.padding(.top, 8)
    }

    var mainRing: some View {
        ZStack {
            Circle().stroke(Color.white.opacity(0.08), lineWidth: 18).frame(width: 190, height: 190)
            let progress = min(1.0, Double(screenTime.todayMinutes) / Double(dailyGoal))
            Circle()
                .trim(from: 0, to: progress)
                .stroke(LinearGradient(colors: [.purple, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing),
                        style: StrokeStyle(lineWidth: 18, lineCap: .round))
                .frame(width: 190, height: 190).rotationEffect(.degrees(-90))
                .animation(.spring(), value: progress)
            VStack(spacing: 4) {
                Text("\(screenTime.todayMinutes)").font(.system(size: 44, weight: .bold)).foregroundColor(.white)
                Text("of \(dailyGoal) min").font(.system(size: 13)).foregroundColor(.gray)
            }
        }.padding(.top, 8)
    }

    var quickStats: some View {
        HStack(spacing: 12) {
            TodayStatBox(icon: "flame.fill",    value: "\(screenTime.pickupCount)",        label: "Pickups",   color: .orange)
            TodayStatBox(icon: "bell.badge.fill", value: "\(screenTime.notificationsCount)", label: "Alerts",    color: .red)
            TodayStatBox(icon: "clock.fill",    value: "\(screenTime.weeklyMinutes/60)h",  label: "This Week", color: .cyan)
        }.padding(.horizontal)
    }

    var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Usage by Category").font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
            if screenTime.categories.isEmpty {
                Text("No data yet.").font(.system(size: 13)).foregroundColor(.gray)
            } else {
                ForEach(screenTime.categories) { cat in
                    CategoryRow(category: cat, total: max(screenTime.todayMinutes, 1))
                }
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.04)).overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.07), lineWidth: 1)))
        .padding(.horizontal)
    }
}

struct TodayStatBox: View {
    let icon: String; let value: String; let label: String; let color: Color
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 16)).foregroundColor(color)
            Text(value).font(.system(size: 18, weight: .bold)).foregroundColor(.white)
            Text(label).font(.system(size: 10)).foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 14)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.04)))
    }
}

// MARK: - Gamified Shield View
struct GamifiedShieldView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedMode: FocusMode = .off
    @State private var sessionActive = false
    @State private var sessionTimer: Timer? = nil
    @State private var sessionElapsed: Int = 0

    let rewards: [ShieldReward] = [
        ShieldReward(icon: "shield.fill",     title: "First Shield",    xpReward: 25,  gemReward: 5,  requirement: "Activate your first focus shield"),
        ShieldReward(icon: "1.circle.fill",   title: "1-Hour Guard",    xpReward: 50,  gemReward: 10, requirement: "Shield active for 1 hour total"),
        ShieldReward(icon: "5.circle.fill",   title: "5-Hour Fortress", xpReward: 100, gemReward: 20, requirement: "Shield active for 5 hours total"),
        ShieldReward(icon: "flame.fill",      title: "Daily Defender",  xpReward: 60,  gemReward: 12, requirement: "Use shield 7 days in a row"),
        ShieldReward(icon: "crown.fill",      title: "Shield Master",   xpReward: 200, gemReward: 40, requirement: "Shield active for 20 hours total"),
    ]

    var body: some View {
        VStack(spacing: 24) {
            shieldHero
            modeSelector
            if sessionActive { activeSessionCard }
            rewardsSection
        }.padding(.top, 8)
        .onDisappear { stopSession() }
    }

    var shieldHero: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(selectedMode == .off ? Color.white.opacity(0.04) : selectedMode.color.opacity(0.12))
                    .frame(width: 160, height: 160).blur(radius: 20)
                Circle()
                    .fill(selectedMode == .off ? Color.white.opacity(0.05) : selectedMode.color.opacity(0.15))
                    .frame(width: 140, height: 140)
                    .overlay(Circle().stroke(selectedMode.color.opacity(selectedMode == .off ? 0.1 : 0.45), lineWidth: 2.5))
                VStack(spacing: 6) {
                    Image(systemName: selectedMode == .off ? "shield.slash" : "shield.checkered")
                        .font(.system(size: 52))
                        .foregroundColor(selectedMode == .off ? .gray : selectedMode.color)
                    if sessionActive {
                        Text(timeString(sessionElapsed))
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            Text(selectedMode == .off ? "Shield Inactive" : "\(selectedMode.rawValue) Active")
                .font(.system(size: 22, weight: .bold)).foregroundColor(.white)

            if selectedMode != .off {
                HStack(spacing: 16) {
                    Label("+5 XP / min", systemImage: "star.fill")
                        .font(.system(size: 12, weight: .semibold)).foregroundColor(.yellow)
                    Label("+1 gem / 5 min", systemImage: "diamond.fill")
                        .font(.system(size: 12, weight: .semibold)).foregroundColor(.cyan)
                }
                .padding(.horizontal, 16).padding(.vertical, 8)
                .background(Capsule().fill(Color.white.opacity(0.07)).overlay(Capsule().stroke(Color.white.opacity(0.1), lineWidth: 1)))
            }
        }
    }

    var modeSelector: some View {
        VStack(spacing: 10) {
            ForEach(FocusMode.allCases.filter { $0 != .custom && $0 != .off }, id: \.self) { mode in
                ShieldModeButton(mode: mode, isSelected: selectedMode == mode) {
                    withAnimation(.spring(response: 0.4)) {
                        if selectedMode == mode {
                            selectedMode = .off; stopSession()
                            ScreenTimeManager.shared.disableShield()
                        } else {
                            selectedMode = mode; startSession()
                            ScreenTimeManager.shared.activateFocusMode(mode)
                        }
                    }
                }
            }
        }.padding(.horizontal)
    }

    var activeSessionCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(selectedMode.color.opacity(0.1))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(selectedMode.color.opacity(0.35), lineWidth: 1))
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(selectedMode.color.opacity(0.2)).frame(width: 48, height: 48)
                    Image(systemName: "timer").font(.system(size: 20)).foregroundColor(selectedMode.color)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("Session Active").font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                    Text("Earning rewards every minute").font(.system(size: 12)).foregroundColor(.white.opacity(0.45))
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 3) {
                    Text("+\(sessionElapsed / 60 * 5) XP").font(.system(size: 13, weight: .bold)).foregroundColor(.yellow)
                    Text("+\(sessionElapsed / 300) gems").font(.system(size: 12)).foregroundColor(.cyan)
                }
            }.padding(16)
        }.padding(.horizontal)
    }

    var rewardsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Shield Achievements")
                .font(.system(size: 18, weight: .bold)).foregroundColor(.white).padding(.horizontal)
            ForEach(rewards) { reward in
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.06)).frame(width: 48, height: 48)
                        Image(systemName: reward.icon).font(.system(size: 20)).foregroundColor(.white.opacity(0.4))
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(reward.title).font(.system(size: 15, weight: .semibold)).foregroundColor(.white.opacity(0.7))
                        Text(reward.requirement).font(.system(size: 11)).foregroundColor(.white.opacity(0.3))
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 3) {
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill").font(.system(size: 9)).foregroundColor(.yellow)
                            Text("+\(reward.xpReward)").font(.system(size: 11, weight: .bold)).foregroundColor(.yellow)
                        }
                        HStack(spacing: 3) {
                            Image(systemName: "diamond.fill").font(.system(size: 9)).foregroundColor(.cyan)
                            Text("+\(reward.gemReward)").font(.system(size: 11, weight: .bold)).foregroundColor(.cyan)
                        }
                    }
                }
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.03)).overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.06), lineWidth: 1)))
                .padding(.horizontal)
            }
        }
    }

    func timeString(_ secs: Int) -> String {
        "\(secs / 60):\(String(format: "%02d", secs % 60))"
    }

    func startSession() {
        sessionActive = true; sessionElapsed = 0
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in
                self.sessionElapsed += 1
                if self.sessionElapsed % 60  == 0 { self.appState.addXP(5) }
                if self.sessionElapsed % 300 == 0 { self.appState.addGems(1) }
            }
        }
    }

    func stopSession() {
        sessionTimer?.invalidate(); sessionTimer = nil
        sessionActive = false; sessionElapsed = 0
    }
}

struct ShieldModeButton: View {
    let mode: FocusMode; let isSelected: Bool; let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(isSelected ? mode.color.opacity(0.25) : Color.white.opacity(0.06))
                        .frame(width: 44, height: 44)
                    Image(systemName: mode.icon).font(.system(size: 20))
                        .foregroundColor(isSelected ? mode.color : .white.opacity(0.5))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(mode.rawValue).font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                    Text(mode.description).font(.system(size: 12)).foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? mode.color : .gray.opacity(0.3)).font(.system(size: 20))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(isSelected ? mode.color.opacity(0.1) : Color.white.opacity(0.04))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(isSelected ? mode.color.opacity(0.45) : Color.white.opacity(0.07), lineWidth: 1.5))
            )
        }
    }
}

// MARK: - Custom Routines View
struct CustomRoutinesView: View {
    @EnvironmentObject var appState: AppState
    @State private var routines: [FocusRoutine] = []
    @State private var showAddRoutine = false
    @State private var editingRoutine: FocusRoutine? = nil

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("ROUTINES")
                        .font(.system(size: 11, weight: .black)).foregroundColor(.white.opacity(0.35)).tracking(2)
                    Text("Your Focus Schedule")
                        .font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                }
                Spacer()
                Button { showAddRoutine = true } label: {
                    Image(systemName: "plus.circle.fill").font(.system(size: 28)).foregroundColor(.purple)
                }
            }
            .padding(.horizontal).padding(.top, 8)

            if routines.isEmpty { emptyState }
            else {
                ForEach($routines) { $routine in
                    RoutineCard2(routine: $routine) {
                        editingRoutine = routine
                    } onDelete: {
                        routines.removeAll { $0.id == routine.id }
                        appState.saveRoutines(routines)
                    }
                }
            }
        }
        .onAppear { routines = appState.savedRoutines }
        .sheet(isPresented: $showAddRoutine) {
            RoutineEditorView(routine: nil) { r in routines.append(r); appState.saveRoutines(routines) }
        }
        .sheet(item: $editingRoutine) { routine in
            RoutineEditorView(routine: routine) { updated in
                if let i = routines.firstIndex(where: { $0.id == updated.id }) { routines[i] = updated }
                else { routines.append(updated) }
                appState.saveRoutines(routines)
            }
        }
    }

    var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.badge.plus").font(.system(size: 44)).foregroundColor(.purple.opacity(0.5))
            Text("No routines yet").font(.system(size: 18, weight: .semibold)).foregroundColor(.white)
            Text("Create a focus routine to block\ndistractions on a schedule.")
                .font(.system(size: 14)).foregroundColor(.gray).multilineTextAlignment(.center)
            Button { showAddRoutine = true } label: {
                Label("Create Routine", systemImage: "plus")
                    .font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                    .padding(.horizontal, 24).padding(.vertical, 13)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.purple))
            }
        }.padding(.vertical, 40)
    }
}

struct RoutineCard2: View {
    @Binding var routine: FocusRoutine
    let onEdit: () -> Void; let onDelete: () -> Void
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Text(routine.emoji).font(.system(size: 26))
                VStack(alignment: .leading, spacing: 3) {
                    Text(routine.name).font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                    Text("\(routine.steps.count) steps · \(routine.totalMinutes) min").font(.system(size: 12)).foregroundColor(.gray)
                }
                Spacer()
                Toggle("", isOn: $routine.isEnabled).tint(.purple).labelsHidden()
            }.padding(16)

            if !routine.steps.isEmpty {
                Divider().background(Color.white.opacity(0.07))
                ForEach(routine.steps) { step in
                    HStack(spacing: 10) {
                        Image(systemName: step.icon).font(.system(size: 13)).foregroundColor(.purple).frame(width: 22)
                        Text(step.label).font(.system(size: 13)).foregroundColor(.white.opacity(0.8))
                        Spacer()
                        Text("\(step.minutes)m").font(.system(size: 12, weight: .medium)).foregroundColor(.gray)
                    }.padding(.horizontal, 16).padding(.vertical, 6)
                }
            }
            Divider().background(Color.white.opacity(0.07))
            HStack {
                Button { onEdit() } label: {
                    Label("Edit", systemImage: "pencil").font(.system(size: 13)).foregroundColor(.purple)
                }
                Spacer()
                Button { onDelete() } label: {
                    Label("Delete", systemImage: "trash").font(.system(size: 13)).foregroundColor(.red.opacity(0.7))
                }
            }.padding(.horizontal, 16).padding(.vertical, 10)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.04))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(routine.isEnabled ? Color.purple.opacity(0.35) : Color.white.opacity(0.07), lineWidth: 1))
        )
        .padding(.horizontal)
    }
}

// MARK: - Routine Editor
struct RoutineEditorView: View {
    @Environment(\.dismiss) var dismiss
    let routine: FocusRoutine?
    let onSave: (FocusRoutine) -> Void

    @State private var name: String = ""
    @State private var emoji: String = "⏰"
    @State private var steps: [RoutineStep] = []
    @State private var showAddStep = false
    @State private var newStepLabel: String = ""
    @State private var newStepMinutes: Int = 25
    @State private var newStepIcon: String = "brain.head.profile"

    let emojiOptions = ["⏰","☀️","🌙","🔥","💪","🧘","📚","🎯","⚡","🛡️"]
    let iconOptions  = ["brain.head.profile","eye.fill","flame.fill","book.fill","cup.and.saucer.fill","figure.walk","moon.fill","wind","music.note","dumbbell.fill"]

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color(hex: "06060F"), Color(hex: "0A0F1C")],
                               startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(emojiOptions, id: \.self) { e in
                                    Button { emoji = e } label: {
                                        Text(e).font(.system(size: 28)).frame(width: 52, height: 52)
                                            .background(Circle().fill(emoji == e ? Color.purple.opacity(0.3) : Color.white.opacity(0.06)))
                                    }
                                }
                            }.padding(.horizontal)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Routine Name").font(.system(size: 13, weight: .semibold)).foregroundColor(.gray)
                            TextField("e.g. Morning Deep Work", text: $name)
                                .foregroundColor(.white).padding(14)
                                .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.06)))
                        }.padding(.horizontal)

                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Steps").font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                                Spacer()
                                Button { showAddStep = true } label: {
                                    Image(systemName: "plus.circle.fill").font(.system(size: 22)).foregroundColor(.purple)
                                }
                            }
                            ForEach(steps) { step in
                                HStack(spacing: 12) {
                                    Image(systemName: step.icon).font(.system(size: 16)).foregroundColor(.purple).frame(width: 24)
                                    Text(step.label).font(.system(size: 14)).foregroundColor(.white)
                                    Spacer()
                                    Text("\(step.minutes)m").font(.system(size: 13, weight: .medium)).foregroundColor(.gray)
                                    Button { steps.removeAll { $0.id == step.id } } label: {
                                        Image(systemName: "xmark.circle.fill").foregroundColor(.red.opacity(0.6)).font(.system(size: 16))
                                    }
                                }
                                .padding(12)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.04)))
                            }
                        }.padding(.horizontal)

                        if showAddStep { addStepForm }
                    }.padding(.vertical)
                }
            }
            .navigationTitle(routine == nil ? "New Routine" : "Edit Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundColor(.gray)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        guard !name.isEmpty else { return }
                        var r = FocusRoutine(name: name, emoji: emoji, steps: steps)
                        if let existing = routine { r.id = existing.id }
                        onSave(r); dismiss()
                    }.foregroundColor(.purple).fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            if let r = routine { name = r.name; emoji = r.emoji; steps = r.steps }
        }
    }

    var addStepForm: some View {
        VStack(spacing: 12) {
            Text("New Step").font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
            TextField("Step label", text: $newStepLabel)
                .foregroundColor(.white).padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.06)))
            Stepper("\(newStepMinutes) minutes", value: $newStepMinutes, in: 1...180).foregroundColor(.white)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(iconOptions, id: \.self) { ic in
                        Button { newStepIcon = ic } label: {
                            Image(systemName: ic).font(.system(size: 18))
                                .foregroundColor(newStepIcon == ic ? .purple : .white.opacity(0.4))
                                .frame(width: 40, height: 40)
                                .background(Circle().fill(newStepIcon == ic ? Color.purple.opacity(0.2) : Color.white.opacity(0.05)))
                        }
                    }
                }
            }
            HStack(spacing: 12) {
                Button { showAddStep = false } label: {
                    Text("Cancel").font(.system(size: 14)).foregroundColor(.gray)
                        .frame(maxWidth: .infinity).padding(.vertical, 12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.05)))
                }
                Button {
                    guard !newStepLabel.isEmpty else { return }
                    steps.append(RoutineStep(label: newStepLabel, minutes: newStepMinutes, icon: newStepIcon))
                    newStepLabel = ""; newStepMinutes = 25; showAddStep = false
                } label: {
                    Text("Add Step").font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.purple))
                }
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.04)).overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.purple.opacity(0.3), lineWidth: 1)))
        .padding(.horizontal)
    }
}

// MARK: - App Blocking View
struct AppBlockingView: View {
    @EnvironmentObject var appState: AppState
    @State private var blockedApps: [BlockedApp] = []
    @State private var showAddApp = false
    @State private var newAppName = ""
    @State private var selectedCategory = "Social"
    let categories = ["Social","Entertainment","Games","Productivity","Shopping","News"]

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("APP BLOCKING")
                        .font(.system(size: 11, weight: .black)).foregroundColor(.white.opacity(0.35)).tracking(2)
                    Text("Block Distractions")
                        .font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                }
                Spacer()
                Button { showAddApp.toggle() } label: {
                    Image(systemName: showAddApp ? "xmark.circle.fill" : "plus.circle.fill")
                        .font(.system(size: 28)).foregroundColor(.red)
                }
            }.padding(.horizontal).padding(.top, 8)

            // Stats banner
            let blocked = blockedApps.filter { $0.isBlocked }.count
            HStack(spacing: 0) {
                VStack(spacing: 2) {
                    Text("\(blocked)").font(.system(size: 22, weight: .bold)).foregroundColor(.red)
                    Text("Blocked").font(.system(size: 11)).foregroundColor(.gray)
                }.frame(maxWidth: .infinity)
                Rectangle().fill(Color.white.opacity(0.08)).frame(width: 1, height: 32)
                VStack(spacing: 2) {
                    Text("\(blockedApps.count - blocked)").font(.system(size: 22, weight: .bold)).foregroundColor(.green)
                    Text("Allowed").font(.system(size: 11)).foregroundColor(.gray)
                }.frame(maxWidth: .infinity)
                Rectangle().fill(Color.white.opacity(0.08)).frame(width: 1, height: 32)
                VStack(spacing: 2) {
                    Text("\(blockedApps.count)").font(.system(size: 22, weight: .bold)).foregroundColor(.white)
                    Text("Total").font(.system(size: 11)).foregroundColor(.gray)
                }.frame(maxWidth: .infinity)
            }
            .padding(.vertical, 14)
            .background(RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.04)).overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.07), lineWidth: 1)))
            .padding(.horizontal)

            if showAddApp { addAppForm }

            VStack(spacing: 8) {
                ForEach($blockedApps) { $app in
                    AppBlockRow(app: $app) {
                        blockedApps.removeAll { $0.id == app.id }
                        appState.saveBlockedApps(blockedApps)
                    }
                }
            }.padding(.horizontal)
        }
        .onAppear { blockedApps = appState.savedBlockedApps }
    }

    var addAppForm: some View {
        VStack(spacing: 12) {
            TextField("App name (e.g. Pinterest)", text: $newAppName)
                .foregroundColor(.white).padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.06)))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(categories, id: \.self) { cat in
                        Button { selectedCategory = cat } label: {
                            Text(cat).font(.system(size: 12, weight: .medium))
                                .foregroundColor(selectedCategory == cat ? .white : .gray)
                                .padding(.horizontal, 12).padding(.vertical, 6)
                                .background(Capsule().fill(selectedCategory == cat ? Color.red.opacity(0.4) : Color.white.opacity(0.06)))
                        }
                    }
                }
            }
            Button {
                guard !newAppName.isEmpty else { return }
                let new = BlockedApp(name: newAppName, icon: "app.fill", category: selectedCategory)
                blockedApps.insert(new, at: 0)
                appState.saveBlockedApps(blockedApps)
                newAppName = ""; showAddApp = false
            } label: {
                Label("Block App", systemImage: "shield.fill")
                    .font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 13)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.red.opacity(0.7)))
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.04)).overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.red.opacity(0.3), lineWidth: 1)))
        .padding(.horizontal)
    }
}

struct AppBlockRow: View {
    @Binding var app: BlockedApp
    let onDelete: () -> Void
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 11)
                    .fill(app.isBlocked ? Color.red.opacity(0.15) : Color.green.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: app.icon).font(.system(size: 18))
                    .foregroundColor(app.isBlocked ? .red : .green)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(app.name).font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                Text(app.category).font(.system(size: 11)).foregroundColor(.gray)
            }
            Spacer()
            Toggle("", isOn: $app.isBlocked).tint(.red).labelsHidden()
            Button(action: onDelete) {
                Image(systemName: "trash").font(.system(size: 14)).foregroundColor(.red.opacity(0.5))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.04))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(app.isBlocked ? Color.red.opacity(0.2) : Color.white.opacity(0.06), lineWidth: 1))
        )
    }
}

// MARK: - Shared helpers reused by TodayView
struct StatBox: View {
    let icon: String; let value: String; let label: String; let color: Color
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 18)).foregroundColor(color)
            Text(value).font(.system(size: 20, weight: .bold)).foregroundColor(.white)
            Text(label).font(.system(size: 10)).foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 14)
        .background(Color.white.opacity(0.05)).cornerRadius(12)
    }
}

struct CategoryRow: View {
    let category: ScreenTimeCategory; let total: Int
    var body: some View {
        let pct = total > 0 ? Double(category.minutes) / Double(total) : 0
        VStack(spacing: 6) {
            HStack {
                Circle().fill(category.color).frame(width: 9, height: 9)
                Text(category.name).font(.system(size: 14)).foregroundColor(.white)
                Spacer()
                Text("\(category.minutes) min").font(.system(size: 13, weight: .medium)).foregroundColor(.gray)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3).fill(Color.white.opacity(0.08))
                    RoundedRectangle(cornerRadius: 3).fill(category.color).frame(width: geo.size.width * pct)
                }
            }.frame(height: 6)
        }
    }
}

struct AppPickerView: View {
    @Binding var isPresented: Bool
    @State private var selection = FamilyActivitySelection()
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0A0F1C").ignoresSafeArea()
                if #available(iOS 16.0, *) {
                    FamilyActivityPicker(selection: $selection)
                } else {
                    Text("Requires iOS 16+").foregroundColor(.gray)
                }
            }
            .navigationTitle("Select Apps").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { isPresented = false }.foregroundColor(.gray) }
                ToolbarItem(placement: .navigationBarTrailing) { Button("Done") { isPresented = false }.foregroundColor(.purple) }
            }
        }
    }
}

#Preview {
    ScreenTimeDashboardView().environmentObject(AppState())
}
