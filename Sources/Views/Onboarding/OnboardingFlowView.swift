import SwiftUI

struct OnboardingFlowView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPage: Int = 0
    @State private var email: String = ""
    @State private var username: String = ""
    @State private var displayName: String = ""
    @State private var selectedAvatar: Int = 0
    @State private var selectedGoal: GoalType = .improve_focus
    @State private var dailyMinutes: Int = 30
    @State private var commitmentDays: Int = 5
    @State private var difficulty: Int = 2
    @State private var selectedAreas: Set<String> = []
    @State private var theme: Int = 0
    @State private var notifications: Bool = true
    @State private var loginMethod: String = "apple"
    @State private var assessmentAnswers: [Int] = []
    @State private var referralCode: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            if currentPage > 0 {
                ProgressBar(current: currentPage, total: 10)
            }
            
            TabView(selection: $currentPage) {
                SplashPage(onNext: { currentPage = 1 }, onSkip: { startGuest() }).tag(0)
                FeatureCarouselPage(onNext: { currentPage = 2 }).tag(1)
                SignUpPage(email: $email, loginMethod: $loginMethod, onNext: { currentPage = 3 }).tag(2)
                ProfileSetupPage(username: $username, displayName: $displayName, selectedAvatar: $selectedAvatar, onNext: { currentPage = 4 }).tag(3)
                GoalSettingPage(selectedGoal: $selectedGoal, dailyMinutes: $dailyMinutes, onNext: { currentPage = 5 }).tag(4)
                CommitmentPage(commitmentDays: $commitmentDays, difficulty: $difficulty, onNext: { currentPage = 6 }).tag(5)
                FocusAreasPage(selectedAreas: $selectedAreas, onNext: { currentPage = 7 }).tag(6)
                PreferencesPage(theme: $theme, notifications: $notifications, onNext: { currentPage = 8 }).tag(7)
                AssessmentPage(assessmentAnswers: $assessmentAnswers, onNext: { currentPage = 9 }).tag(8)
                ReferralPage(referralCode: $referralCode, onNext: { currentPage = 10 }).tag(9)
                CompletionPage(onComplete: { completeOnboarding() }).tag(10)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .preferredColorScheme(theme == 0 ? .dark : .light)
    }
    
    func startGuest() {
        username = "Guest"
        displayName = "Guest User"
        currentPage = 10
    }
    
    func completeOnboarding() {
        let data = OnboardingData(screenTime: Double(dailyMinutes), baselineScore: Int(dailyMinutes * 20), commitmentLevel: commitmentDays, selectedGoal: selectedGoal)
        var user = appState.currentUser ?? User(id: UUID().uuidString, email: "guest@local", createdAt: Date(), goal: selectedGoal, isPremium: false, onboardingData: data)
        user.goal = selectedGoal
        user.onboardingData = data
        user.displayName = displayName.isEmpty ? username : displayName
        appState.currentUser = user
        appState.isOnboarded = true
        appState.progress = GameProgress(level: 1, totalXP: 100, streakDays: 0, lastActivityDate: nil, hearts: 5, gems: 10, completedChallenges: [], skills: [:])
        appState.saveData()
    }
}

struct ProgressBar: View {
    let current: Int
    let total: Int
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<total - 1, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2).fill(index <= current ? Color.purple : Color.white.opacity(0.2)).frame(height: 4)
            }
        }.padding(.horizontal, 24).padding(.top, 16)
    }
}

struct SplashPage: View {
    var onNext: () -> Void
    var onSkip: () -> Void
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "0A0F1C"), Color(hex: "1E293B")], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack(spacing: 32) {
                Spacer()
                ZStack {
                    Circle().fill(LinearGradient(colors: [.purple, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(width: 120, height: 120)
                    Image(systemName: "brain.head.profile").font(.system(size: 50, weight: .bold)).foregroundColor(.white)
                }
                VStack(spacing: 12) {
                    Text("FocusFlow").font(.system(size: 40, weight: .bold)).foregroundColor(.white)
                    Text("Master your mind").font(.system(size: 18)).foregroundColor(.gray)
                }
                VStack(spacing: 8) {
                    HStack { ForEach(0..<5) { _ in Image(systemName: "star.fill").foregroundColor(.yellow) }; Text("4.9").font(.system(size: 14, weight: .semibold)).foregroundColor(.white) }
                    Text("10,000+ users").font(.system(size: 14)).foregroundColor(.gray)
                }.padding(.top, 20)
                Spacer()
                VStack(spacing: 16) {
                    Button(action: onNext) { Text("Get Started").font(.system(size: 18, weight: .bold)).foregroundColor(.white).frame(maxWidth: .infinity).frame(height: 56).background(LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing)).cornerRadius(28) }
                    Button(action: onSkip) { Text("Continue as Guest").font(.system(size: 16)).foregroundColor(.gray) }
                }.padding(.horizontal, 32).padding(.bottom, 40)
            }
        }
    }
}

struct FeatureCarouselPage: View {
    var onNext: () -> Void
    let features = [("brain.head.profile", "Brain Training", Color.purple), ("flame.fill", "Build Streaks", Color.orange), ("chart.line.uptrend.xyaxis", "Track Progress", Color.cyan), ("crown.fill", "Earn Rewards", Color.yellow), ("person.3.fill", "Compete Together", Color.green)]
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "0A0F1C"), Color(hex: "1E293B")], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack(spacing: 32) {
                HStack { Spacer(); Button(action: onNext) { Text("Skip").foregroundColor(.gray) }.padding(.trailing, 24).padding(.top, 16) }
                Spacer()
                TabView { ForEach(0..<features.count, id: \.self) { index in VStack(spacing: 24) { ZStack { Circle().fill(features[index].2.opacity(0.2)).frame(width: 120, height: 120); Image(systemName: features[index].0).font(.system(size: 50)).foregroundColor(features[index].2) }; Text(features[index].1).font(.system(size: 28, weight: .bold)).foregroundColor(.white) } } }.tabViewStyle(.page(indexDisplayMode: .never)).frame(height: 350)
                Spacer()
                Button(action: onNext) { Text("Next").font(.system(size: 18, weight: .bold)).foregroundColor(.white).frame(maxWidth: .infinity).frame(height: 56).background(Color.purple).cornerRadius(28) }.padding(.horizontal, 32).padding(.bottom, 40)
            }
        }
    }
}

struct SignUpPage: View {
    @Binding var email: String
    @Binding var loginMethod: String
    var onNext: () -> Void
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "0A0F1C"), Color(hex: "1E293B")], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack(spacing: 32) {
                VStack(spacing: 12) { Text("Create Account").font(.system(size: 32, weight: .bold)).foregroundColor(.white); Text("Join thousands improving focus").foregroundColor(.gray) }.padding(.top, 40)
                VStack(spacing: 16) {
                    Button(action: { loginMethod = "apple"; onNext() }) { HStack { Image(systemName: "apple.logo"); Text("Continue with Apple"); Spacer() }.foregroundColor(.white).padding().background(Color.white.opacity(0.1)).cornerRadius(12) }.padding(.horizontal, 24)
                    Button(action: { loginMethod = "google"; onNext() }) { HStack { Image(systemName: "g.circle.fill").foregroundColor(.blue); Text("Continue with Google"); Spacer() }.foregroundColor(.white).padding().background(Color.white.opacity(0.1)).cornerRadius(12) }.padding(.horizontal, 24)
                    HStack { Rectangle().fill(Color.white.opacity(0.2)).frame(height: 1); Text("or").foregroundColor(.gray); Rectangle().fill(Color.white.opacity(0.2)).frame(height: 1) }.padding(.horizontal)
                    VStack(spacing: 12) {
                        TextField("Email", text: $email).textFieldStyle(STYLE()).autocapitalization(.none)
                        Button(action: onNext) { Text("Continue").font(.system(size: 16, weight: .semibold)).foregroundColor(.white).frame(maxWidth: .infinity).frame(height: 50).background(email.isEmpty ? Color.gray : Color.purple).cornerRadius(12) }.disabled(email.isEmpty)
                    }.padding(.horizontal, 24)
                    Button(action: { loginMethod = "guest"; onNext() }) { Text("Continue as Guest").foregroundColor(.gray) }.padding(.top, 8)
                }
                Spacer()
            }
        }
    }
}

struct STYLE: TextFieldStyle { func _body(configuration: TextField<Self._Label>) -> some View { configuration.padding().background(Color.white.opacity(0.1)).cornerRadius(12).foregroundColor(.white) } }

struct ProfileSetupPage: View {
    @Binding var username: String
    @Binding var displayName: String
    @Binding var selectedAvatar: Int
    var onNext: () -> Void
    let avatars = ["🦊", "🐼", "🦁", "🐯", "🐨", "🐰", "🦄", "🐲", "🦋", "🐙", "🦩", "🐳"]
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "0A0F1C"), Color(hex: "1E293B")], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            ScrollView { VStack(spacing: 24) { Text("Set Up Profile").font(.system(size: 28, weight: .bold)).foregroundColor(.white)
                ZStack { Circle().fill(LinearGradient(colors: [.purple, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(width: 100, height: 100); Text(avatars[selectedAvatar]).font(.system(size: 50)) }
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) { ForEach(0..<avatars.count, id: \.self) { index in Text(avatars[index]).font(.system(size: 30)).padding(8).background(selectedAvatar == index ? Color.purple.opacity(0.3) : Color.clear).cornerRadius(8).onTapGesture { selectedAvatar = index } } }.padding(.horizontal)
                VStack(spacing: 12) { TextField("Username", text: $username).textFieldStyle(STYLE()); TextField("Display Name", text: $displayName).textFieldStyle(STYLE()) }.padding(.horizontal, 24)
                Button(action: onNext) { Text(username.isEmpty ? "Choose Username" : "Continue").font(.system(size: 18, weight: .bold)).foregroundColor(.white).frame(maxWidth: .infinity).frame(height: 56).background(username.isEmpty ? Color.gray : Color.purple).cornerRadius(28) }.disabled(username.isEmpty).padding(.horizontal, 32).padding(.bottom, 40) }.padding(.top, 40) }
        }
    }
}

struct GoalSettingPage: View {
    @Binding var selectedGoal: GoalType
    @Binding var dailyMinutes: Int
    var onNext: () -> Void
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "0A0F1C"), Color(hex: "1E293B")], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            ScrollView { VStack(spacing: 24) { Text("What's Your Goal?").font(.system(size: 28, weight: .bold)).foregroundColor(.white)
                VStack(spacing: 12) {
                    ForEach([GoalType.improve_focus, .reduce_screen_time, .build_discipline, .increase_productivity], id: \.self) { goal in Button(action: { selectedGoal = goal }) { HStack { Text(goal == .improve_focus ? "🎯" : goal == .reduce_screen_time ? "📱" : goal == .build_discipline ? "💪" : "⚡").font(.system(size: 30)); Text(goal.rawValue).foregroundColor(.white); Spacer(); if selectedGoal == goal { Image(systemName: "checkmark.circle.fill").foregroundColor(.purple) } }.padding(20).background(selectedGoal == goal ? Color.purple.opacity(0.2) : Color.white.opacity(0.05)).cornerRadius(16).overlay(RoundedRectangle(cornerRadius: 16).stroke(selectedGoal == goal ? Color.purple : Color.white.opacity(0.1), lineWidth: 2)) } }
                }.padding(.horizontal, 24)
                VStack(spacing: 12) { Text("Daily Practice Time").foregroundColor(.white); HStack { Text("\(dailyMinutes)").font(.system(size: 36, weight: .bold)).foregroundColor(.purple); Text("min").foregroundColor(.gray) }; Slider(value: Binding(get: { Double(dailyMinutes) }, set: { dailyMinutes = Int($0) }), in: 5...120, step: 5).accentColor(.purple) }.padding(24).background(Color.white.opacity(0.05)).cornerRadius(16).padding(.horizontal, 24)
                Button(action: onNext) { Text("Continue").font(.system(size: 18, weight: .bold)).foregroundColor(.white).frame(maxWidth: .infinity).frame(height: 56).background(Color.purple).cornerRadius(28) }.padding(.horizontal, 32).padding(.bottom, 40) }.padding(.top, 40) }
        }
    }
}

struct CommitmentPage: View {
    @Binding var commitmentDays: Int
    @Binding var difficulty: Int
    var onNext: () -> Void
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "0A0F1C"), Color(hex: "1E293B")], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack(spacing: 24) { Text("Set Your Commitment").font(.system(size: 28, weight: .bold)).foregroundColor(.white)
                VStack(spacing: 12) { Text("Days per week").foregroundColor(.white); HStack(spacing: 12) { ForEach(1...7, id: \.self) { day in Button(action: { commitmentDays = day }) { Text("\(day)").font(.system(size: 18, weight: .bold)).foregroundColor(commitmentDays == day ? .white : .gray).frame(width: 40, height: 40).background(commitmentDays == day ? Color.purple : Color.white.opacity(0.1)).cornerRadius(8) } } } }.padding(24).background(Color.white.opacity(0.05)).cornerRadius(16).padding(.horizontal, 24)
                VStack(spacing: 12) { Text("Difficulty").foregroundColor(.white); ForEach(1...3, id: \.self) { d in Button(action: { difficulty = d }) { HStack { Text(["Beginner", "Intermediate", "Advanced"][d-1]).foregroundColor(.white); Spacer(); if difficulty == d { Image(systemName: "checkmark.circle.fill").foregroundColor(.purple) } }.padding(16).background(difficulty == d ? Color.purple.opacity(0.2) : Color.white.opacity(0.05)).cornerRadius(12) } } }.padding(24).background(Color.white.opacity(0.05)).cornerRadius(16).padding(.horizontal, 24)
                Spacer()
                Button(action: onNext) { Text("Continue").font(.system(size: 18, weight: .bold)).foregroundColor(.white).frame(maxWidth: .infinity).frame(height: 56).background(Color.purple).cornerRadius(28) }.padding(.horizontal, 32).padding(.bottom, 40) }
        }
    }
}

struct FocusAreasPage: View {
    @Binding var selectedAreas: Set<String>
    var onNext: () -> Void
    let areas = [("📊", "Analytics"), ("🎯", "Attention"), ("🧠", "Memory"), ("⏱️", "Productivity"), ("😴", "Relaxation"), ("📖", "Learning"), ("🧘", "Mindfulness"), ("💪", "Discipline")]
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "0A0F1C"), Color(hex: "1E293B")], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack(spacing: 24) { Text("Focus Areas").font(.system(size: 28, weight: .bold)).foregroundColor(.white); Text("Select areas to improve").foregroundColor(.gray)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) { ForEach(areas, id: \.1) { area in Button(action: { if selectedAreas.contains(area.1) { selectedAreas.remove(area.1) } else { selectedAreas.insert(area.1) } }) { VStack(spacing: 8) { Text(area.0).font(.system(size: 30)); Text(area.1).foregroundColor(.white) }.frame(maxWidth: .infinity).padding(.vertical, 20).background(selectedAreas.contains(area.1) ? Color.purple.opacity(0.3) : Color.white.opacity(0.05)).cornerRadius(16).overlay(RoundedRectangle(cornerRadius: 16).stroke(selectedAreas.contains(area.1) ? Color.purple : Color.white.opacity(0.1), lineWidth: 2)) } } }.padding(.horizontal, 24)
                Spacer()
                Button(action: onNext) { Text("Continue").font(.system(size: 18, weight: .bold)).foregroundColor(.white).frame(maxWidth: .infinity).frame(height: 56).background(Color.purple).cornerRadius(28) }.padding(.horizontal, 32).padding(.bottom, 40) }
        }
    }
}

struct PreferencesPage: View {
    @Binding var theme: Int
    @Binding var notifications: Bool
    var onNext: () -> Void
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "0A0F1C"), Color(hex: "1E293B")], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack(spacing: 24) { Text("Preferences").font(.system(size: 28, weight: .bold)).foregroundColor(.white)
                VStack(alignment: .leading, spacing: 12) { Text("Appearance").foregroundColor(.white); HStack(spacing: 12) { Button(action: { theme = 0 }) { VStack { Image(systemName: "moon.fill").foregroundColor(theme == 0 ? .white : .gray); Text("Dark").foregroundColor(theme == 0 ? .white : .gray) }.frame(maxWidth: .infinity).padding(.vertical, 16).background(theme == 0 ? Color.purple : Color.white.opacity(0.05)).cornerRadius(12) }; Button(action: { theme = 1 }) { VStack { Image(systemName: "sun.max.fill").foregroundColor(theme == 1 ? .white : .gray); Text("Light").foregroundColor(theme == 1 ? .white : .gray) }.frame(maxWidth: .infinity).padding(.vertical, 16).background(theme == 1 ? Color.purple : Color.white.opacity(0.05)).cornerRadius(12) } } }.padding(20).background(Color.white.opacity(0.05)).cornerRadius(16).padding(.horizontal, 24)
                VStack(spacing: 12) { Toggle(isOn: $notifications) { HStack { Image(systemName: "bell.fill").foregroundColor(.purple); Text("Push Notifications").foregroundColor(.white) } }.toggleStyle(SwitchToggleStyle(tint: .purple)) }.padding(20).background(Color.white.opacity(0.05)).cornerRadius(16).padding(.horizontal, 24)
                Button(action: onNext) { Text("Continue").font(.system(size: 18, weight: .bold)).foregroundColor(.white).frame(maxWidth: .infinity).frame(height: 56).background(Color.purple).cornerRadius(28) }.padding(.horizontal, 32).padding(.bottom, 40) }
        }
    }
}

struct AssessmentPage: View {
    @Binding var assessmentAnswers: [Int]
    var onNext: () -> Void
    let questions = [("How often distracted?", ["Rarely", "Sometimes", "Often", "Very"]), ("Remember names?", ["Excellent", "Good", "Okay", "Poor"]), ("How focused?", ["Very", "Somewhat", "Not much", "Not"])]
    @State private var currentQ = 0
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "0A0F1C"), Color(hex: "1E293B")], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack(spacing: 24) { Text("Quick Assessment").font(.system(size: 28, weight: .bold)).foregroundColor(.white); Text("Optional").foregroundColor(.gray)
                HStack(spacing: 4) { ForEach(0..<questions.count, id: \.self) { i in Circle().fill(i <= currentQ ? Color.purple : Color.white.opacity(0.2)).frame(width: 8, height: 8) } }
                VStack(spacing: 20) { Text("Question \(currentQ + 1)/\(questions.count)").foregroundColor(.gray); Text(questions[currentQ].0).font(.system(size: 22, weight: .semibold)).foregroundColor(.white).multilineTextAlignment(.center); ForEach(0..<4, id: \.self) { answer in Button(action: { assessmentAnswers.append(answer); if currentQ < questions.count - 1 { currentQ += 1 } else { onNext() } }) { Text(questions[currentQ].1[answer]).foregroundColor(.white).frame(maxWidth: .infinity).padding(16).background(Color.white.opacity(0.1)).cornerRadius(12) } } }.padding(.horizontal, 24)
                Spacer()
                Button(action: onNext) { Text("Skip").foregroundColor(.gray) }.padding(.bottom, 40) }
        }
    }
}

struct ReferralPage: View {
    @Binding var referralCode: String
    var onNext: () -> Void
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "0A0F1C"), Color(hex: "1E293B")], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack(spacing: 32) { Spacer(); Image(systemName: "gift.fill").font(.system(size: 80)).foregroundColor(.purple); VStack(spacing: 12) { Text("Have a Referral Code?").font(.system(size: 28, weight: .bold)).foregroundColor(.white); Text("Enter for +50 Gems!").foregroundColor(.gray) }.padding(.horizontal, 32); TextField("Enter code", text: $referralCode).textFieldStyle(STYLE()).textInputAutocapitalization(.characters).padding(.horizontal, 40).padding(.top, 20); Spacer(); Button(action: onNext) { Text("Continue").font(.system(size: 18, weight: .bold)).foregroundColor(.white).frame(maxWidth: .infinity).frame(height: 56).background(Color.purple).cornerRadius(28) }.padding(.horizontal, 32).padding(.bottom, 40) }
        }
    }
}

struct CompletionPage: View {
    var onComplete: () -> Void
    @State private var showRewards = false
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "0A0F1C"), Color(hex: "1E293B")], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack(spacing: 32) { Spacer(); Text("🎉").font(.system(size: 80)); VStack(spacing: 16) { Text("Welcome to FocusFlow!").font(.system(size: 32, weight: .bold)).foregroundColor(.white); Text("Your journey starts now").foregroundColor(.gray) }
                if showRewards { HStack(spacing: 24) { VStack { Image(systemName: "star.fill").font(.system(size: 30)).foregroundColor(.purple); Text("+100").font(.system(size: 20, weight: .bold)).foregroundColor(.white); Text("XP").foregroundColor(.gray) }; VStack { Image(systemName: "diamond.fill").font(.system(size: 30)).foregroundColor(.cyan); Text("+10").font(.system(size: 20, weight: .bold)).foregroundColor(.white); Text("Gems").foregroundColor(.gray) }; VStack { Image(systemName: "heart.fill").font(.system(size: 30)).foregroundColor(.red); Text("+5").font(.system(size: 20, weight: .bold)).foregroundColor(.white); Text("Hearts").foregroundColor(.gray) } }.transition(.scale.combined(with: .opacity)) }
                Spacer()
                Button(action: onComplete) { Text("Start Training").font(.system(size: 18, weight: .bold)).foregroundColor(.white).frame(maxWidth: .infinity).frame(height: 56).background(LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing)).cornerRadius(28) }.padding(.horizontal, 32).padding(.bottom, 40) }
        }.onAppear { withAnimation(.spring().delay(0.3)) { showRewards = true } }
    }
}
