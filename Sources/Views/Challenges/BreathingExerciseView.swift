import SwiftUI

// MARK: - Breathing Exercise View
// Multiple breathing patterns: 4-7-8, Box Breathing, Relaxing Breath, Energizing Breath

// MARK: - Mood Enum
enum Mood: String, CaseIterable {
    case terrible = "Terrible"
    case bad = "Bad"
    case okay = "Okay"
    case good = "Good"
    case great = "Great"
    
    var emoji: String {
        switch self {
        case .terrible: return "😫"
        case .bad: return "😔"
        case .okay: return "😐"
        case .good: return "🙂"
        case .great: return "😄"
        }
    }
    
    var color: Color {
        switch self {
        case .terrible: return .red
        case .bad: return .orange
        case .okay: return .yellow
        case .good: return Color.green.opacity(0.7)
        case .great: return .green
        }
    }
    
    var numericValue: Int {
        switch self {
        case .terrible: return 1
        case .bad: return 2
        case .okay: return 3
        case .good: return 4
        case .great: return 5
        }
    }
}

struct BreathingExerciseView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedPattern: BreathingPattern = .box
    @State private var isActive: Bool = false
    @State private var phase: BreathPhase = .inhale
    @State private var progress: Double = 0
    @State private var cycleCount: Int = 0
    @State private var sessionDuration: Int = 60 // seconds
    @State private var timeRemaining: Int = 60
    @State private var showSettings: Bool = false
    @State private var audioManager = AppAudioManager.shared
    
    @State private var sessionComplete: Bool = false
    
    // Mood tracking
    @State private var showMoodSelection: Bool = true
    @State private var preSessionMood: Mood?
    @State private var postSessionMood: Mood?
    @State private var moodPhase: MoodSelectionPhase = .pre
    
    enum MoodSelectionPhase {
        case pre
        case post
    }
    
    enum BreathingPattern: String, CaseIterable {
        case box = "Box Breathing"
        case relaxing = "4-7-8 Relaxing"
        case energizing = "Energizing"
        case coherent = "Coherent"
        
        var description: String {
            switch self {
            case .box: return "4s inhale, 4s hold, 4s exhale, 4s hold"
            case .relaxing: return "4s inhale, 7s hold, 8s exhale"
            case .energizing: return "4s inhale, 2s hold, 4s exhale"
            case .coherent: return "5s inhale, 5s exhale"
            }
        }
        
        var totalCycleTime: Int {
            switch self {
            case .box: return 16
            case .relaxing: return 19
            case .energizing: return 10
            case .coherent: return 10
            }
        }
        
        func phaseTime(for phase: BreathPhase) -> Int {
            switch self {
            case .box:
                switch phase {
                case .inhale: return 4
                case .holdAfterInhale: return 4
                case .exhale: return 4
                case .holdAfterExhale: return 4
                }
            case .relaxing:
                switch phase {
                case .inhale: return 4
                case .holdAfterInhale: return 7
                case .exhale: return 8
                case .holdAfterExhale: return 0
                }
            case .energizing:
                switch phase {
                case .inhale: return 4
                case .holdAfterInhale: return 2
                case .exhale: return 4
                case .holdAfterExhale: return 0
                }
            case .coherent:
                switch phase {
                case .inhale: return 5
                case .holdAfterInhale: return 0
                case .exhale: return 5
                case .holdAfterExhale: return 0
                }
            }
        }
    }
    
    enum BreathPhase: String {
        case inhale = "Breathe In"
        case holdAfterInhale = "Hold after inhale"
        case exhale = "Breathe Out"
        case holdAfterExhale = "Hold after exhale"
    }
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Background
            backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                header
                
                if showMoodSelection && moodPhase == .pre {
                    moodSelectionView(isPreSession: true)
                } else if !isActive && !sessionComplete {
                    patternSelection
                } else if sessionComplete {
                    if postSessionMood == nil && moodPhase == .post {
                        moodSelectionView(isPreSession: false)
                    } else {
                        resultsView
                    }
                } else {
                    breathingCircle
                }
            }
        }
        .onReceive(timer) { _ in
            if isActive && !sessionComplete {
                tick()
            }
        }
    }
    
    // MARK: - Mood Selection View
    
    func moodSelectionView(isPreSession: Bool) -> some View {
        VStack(spacing: 32) {
            Spacer()
            
            Text(isPreSession ? "How are you feeling?" : "How do you feel now?")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text(isPreSession ? "Check in before your breathing session" : "Check in after your breathing session")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            // Mood options
            HStack(spacing: 12) {
                ForEach(Mood.allCases, id: \.self) { mood in
                    Button {
                        if isPreSession {
                            preSessionMood = mood
                        } else {
                            postSessionMood = mood
                        }
                    } label: {
                        VStack(spacing: 8) {
                            Text(mood.emoji)
                                .font(.system(size: 40))
                            Text(mood.rawValue)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .frame(width: 60, height: 80)
                        .background(
                            (isPreSession ? preSessionMood == mood : postSessionMood == mood) 
                            ? mood.color.opacity(0.3) 
                            : Color.white.opacity(0.05)
                        )
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    (isPreSession ? preSessionMood == mood : postSessionMood == mood) 
                                    ? mood.color 
                                    : Color.clear, 
                                    lineWidth: 2
                                )
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Continue button
            if (isPreSession && preSessionMood != nil) || (!isPreSession && postSessionMood != nil) {
                Button {
                    if isPreSession {
                        showMoodSelection = false
                    } else {
                        postSessionMood = postSessionMood ?? preSessionMood
                        // Auto-advance to results
                    }
                } label: {
                    Text(isPreSession ? "Continue" : "See Results")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(16)
                }
                .padding(.horizontal, 40)
            }
            
            if isPreSession {
                Button {
                    showMoodSelection = false
                    preSessionMood = .okay // Default
                } label: {
                    Text("Skip")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 20)
            }
        }
    }
    
    var backgroundGradient: some View {
        LinearGradient(
            colors: [Color("0A0F1C"), Color("1E293B")],
            startPoint: .top,
            endPoint: .bottom
        )
        .overlay(
            // Animated gradient based on phase
            Circle()
                .fill(phaseGradient)
                .frame(width: 400, height: 400)
                .blur(radius: 100)
                .opacity(0.3)
                .offset(y: 100)
        )
    }
    
    var phaseGradient: LinearGradient {
        switch phase {
        case .inhale:
            return LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom)
        case .holdAfterInhale:
            return LinearGradient(colors: [.purple, .indigo], startPoint: .top, endPoint: .bottom)
        case .exhale:
            return LinearGradient(colors: [.green, .teal], startPoint: .top, endPoint: .bottom)
        case .holdAfterExhale:
            return LinearGradient(colors: [.orange, .yellow], startPoint: .top, endPoint: .bottom)
        }
    }
    
    var header: some View {
        HStack {
            Button {
                if isActive {
                    isActive = false
                }
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            if isActive {
                // Timer
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                    Text("\(timeRemaining)s")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.1))
                .cornerRadius(20)
            }
            
            Spacer()
            
            // Cycles count
            if isActive {
                Text("\(cycleCount) cycles")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            } else {
                Button {
                    showSettings.toggle()
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 60)
    }
    
    var patternSelection: some View {
        VStack(spacing: 32) {
            Text("Choose Your Breath")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            // Pattern cards
            VStack(spacing: 16) {
                ForEach(BreathingPattern.allCases, id: \.self) { pattern in
                    PatternCard(
                        pattern: pattern,
                        isSelected: selectedPattern == pattern
                    ) {
                        selectedPattern = pattern
                    }
                }
            }
            .padding(.horizontal, 24)
            
            // Duration selector
            VStack(spacing: 12) {
                Text("Duration")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                HStack(spacing: 12) {
                    ForEach([60, 120, 180, 300], id: \.self) { duration in
                        Button {
                            sessionDuration = duration
                        } label: {
                            Text("\(duration / 60)m")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(sessionDuration == duration ? .white : .gray)
                                .frame(width: 50, height: 40)
                                .background(sessionDuration == duration ? Color.purple : Color.white.opacity(0.1))
                                .cornerRadius(10)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Start button
            Button {
                startSession()
            } label: {
                Text("Begin Session")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(16)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
    
    var breathingCircle: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Main breathing circle
            ZStack {
                // Outer glow
                Circle()
                    .fill(phaseColor.opacity(0.2))
                    .frame(width: circleSize + 60, height: circleSize + 60)
                    .blur(radius: 20)
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(phaseColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: circleSize + 30, height: circleSize + 30)
                    .rotationEffect(.degrees(-90))
                
                // Main circle
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [phaseColor.opacity(0.8), phaseColor.opacity(0.3)],
                            center: .center,
                            startRadius: 0,
                            endRadius: circleSize / 2
                        )
                    )
                    .frame(width: circleSize, height: circleSize)
                
                // Phase text
                VStack(spacing: 8) {
                    Text(phase.rawValue)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(phaseTimeText)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            // Pattern info
            VStack(spacing: 4) {
                Text(selectedPattern.rawValue)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(selectedPattern.description)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Pause/Stop button
            Button {
                isActive = false
            } label: {
                HStack {
                    Image(systemName: "stop.fill")
                    Text("End Session")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.red.opacity(0.3))
                .cornerRadius(25)
            }
            .padding(.bottom, 40)
        }
    }
    
    var resultsView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Session Complete!")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            // Mood improvement (if tracked)
            if let pre = preSessionMood, let post = postSessionMood {
                moodImprovementView(pre: pre, post: post)
            }
            
            VStack(spacing: 16) {
                resultRow(icon: "arrow.clockwise", label: "Cycles Completed", value: "\(cycleCount)")
                resultRow(icon: "clock", label: "Duration", value: "\(sessionDuration / 60) min")
                resultRow(icon: "leaf.fill", label: "Pattern", value: selectedPattern.rawValue)
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 30)
            .background(Color.white.opacity(0.1))
            .cornerRadius(20)
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Text("Done")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.purple)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
    
    func moodImprovementView(pre: Mood, post: Mood) -> some View {
        let improvement = post.numericValue - pre.numericValue
        let improvementText: String
        let improvementIcon: String
        let improvementColor: Color
        
        if improvement > 0 {
            improvementText = "+\(improvement) mood points"
            improvementIcon = "arrow.up.circle.fill"
            improvementColor = .green
        } else if improvement < 0 {
            improvementText = "\(improvement) mood points"
            improvementIcon = "arrow.down.circle.fill"
            improvementColor = .orange
        } else {
            improvementText = "No change"
            improvementIcon = "minus.circle.fill"
            improvementColor = .gray
        }
        
        return VStack(spacing: 16) {
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("Before")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Text(pre.emoji)
                        .font(.system(size: 32))
                }
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 20))
                    .foregroundColor(.gray)
                
                VStack(spacing: 4) {
                    Text("After")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Text(post.emoji)
                        .font(.system(size: 32))
                }
            }
            
            HStack(spacing: 6) {
                Image(systemName: improvementIcon)
                    .foregroundColor(improvementColor)
                Text(improvementText)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(improvementColor)
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    func resultRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.purple)
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Computed Properties
    
    var circleSize: CGFloat {
        let base: CGFloat = 200
        let minSize: CGFloat = 150
        let maxSize: CGFloat = 280
        
        switch phase {
        case .inhale:
            return base + (maxSize - base) * progress
        case .holdAfterInhale:
            return maxSize
        case .exhale:
            return maxSize - (maxSize - minSize) * progress
        case .holdAfterExhale:
            return minSize
        }
    }
    
    var phaseColor: Color {
        switch phase {
        case .inhale: return .cyan
        case .holdAfterInhale: return .purple
        case .exhale: return .green
        case .holdAfterExhale: return .orange
        }
    }
    
    var phaseTimeText: String {
        let phaseTime = selectedPattern.phaseTime(for: phase)
        let remaining = Int(Double(phaseTime) * (1 - progress))
        return "\(max(0, remaining))"
    }
    
    // MARK: - Logic
    
    func startSession() {
        cycleCount = 0
        timeRemaining = sessionDuration
        progress = 0
        phase = .inhale
        isActive = true
        sessionComplete = false
    }
    
    func tick() {
        timeRemaining -= 1
        
        if timeRemaining <= 0 {
            endSession()
            return
        }
        
        let phaseTime = selectedPattern.phaseTime(for: phase)
        if phaseTime > 0 {
            progress += 0.1 / Double(phaseTime)
            
            if progress >= 1.0 {
                progress = 0
                advancePhase()
            }
        } else {
            // Skip zero-time phases
            advancePhase()
        }
    }
    
    func advancePhase() {
        switch phase {
        case .inhale:
            if selectedPattern.phaseTime(for: .holdAfterInhale) > 0 {
                phase = .holdAfterInhale
            } else {
                phase = .exhale
            }
        case .holdAfterInhale:
            phase = .exhale
        case .exhale:
            if selectedPattern.phaseTime(for: .holdAfterExhale) > 0 {
                phase = .holdAfterExhale
            } else {
                phase = .inhale
                cycleCount += 1
                audioManager.success()
            }
        case .holdAfterExhale:
            phase = .inhale
            cycleCount += 1
            audioManager.success()
        }
    }
    
    func endSession() {
        isActive = false
        sessionComplete = true
        audioManager.playChallengeComplete()
        
        // Show post-session mood if pre-session was tracked
        if preSessionMood != nil {
            moodPhase = .post
            // Keep sessionComplete but show mood selection overlay
            // The UI logic handles showing mood selection when postSessionMood is nil
        }
    }
}

// MARK: - Pattern Card

struct PatternCard: View {
    let pattern: BreathingExerciseView.BreathingPattern
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(pattern.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(pattern.description)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .green : .gray)
            }
            .padding(16)
            .background(isSelected ? Color.purple.opacity(0.3) : Color.white.opacity(0.05))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.purple : Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

#Preview {
    BreathingExerciseView()
}
