import SwiftUI

// MARK: - Scroll Stopping Overlay
struct ScrollStoppingOverlay: View {
    @Binding var isPresented: Bool
    let onComplete: () -> Void
    let onSkip: () -> Void
    let skipRemaining: Int
    
    @State private var selectedAnswer: Int?
    @State private var showResult: Bool = false
    @State private var isCorrect: Bool = false
    
    // Quick trivia questions
    let questions: [(String, [String], Int)] = [
        ("What is the Pomodoro technique?", ["25 min work, 5 min break", "50 min work, 10 min break", "30 min work, 15 min break", "1 hour work, 30 min break"], 0),
        ("How many hours of sleep do adults need?", ["5-6 hours", "7-9 hours", "10-12 hours", "4-5 hours"], 1),
        ("What boosts dopamine naturally?", ["Scrolling social media", "Completing tasks", "Checking emails", "Watching TV"], 1),
        ("Best time to do deep work?", ["Morning", "Afternoon", "Evening", "Late night"], 0),
        ("What helps with focus most?", ["Multitasking", "Single-tasking", "Listening to music", "Having background noise"], 1),
    ]
    
    @State private var currentQuestionIndex: Int = 0
    
    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    // Prevent dismissal by tapping outside
                }
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                    
                    Text("Pause & Focus")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("You've been scrolling a while. Take a quick mental break!")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 24)
                
                Spacer()
                
                // Question
                if currentQuestionIndex < questions.count {
                    let question = questions[currentQuestionIndex]
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Question \(currentQuestionIndex + 1)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.purple)
                        
                        Text(question.0)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        VStack(spacing: 12) {
                            ForEach(0..<question.1.count, id: \.self) { index in
                                AnswerButton(
                                    text: question.1[index],
                                    isSelected: selectedAnswer == index,
                                    isCorrect: showResult ? (index == question.2) : nil,
                                    isWrong: showResult && selectedAnswer == index && index != question.2
                                ) {
                                    selectedAnswer = index
                                    checkAnswer(index: index, correctIndex: question.2)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                
                Spacer()
                
                // Skip button
                if skipRemaining > 0 {
                    Button {
                        onSkip()
                    } label: {
                        Text("Skip (\(skipRemaining) remaining)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 24)
                }
                
                // Progress
                HStack(spacing: 4) {
                    ForEach(0..<questions.count, id: \.self) { index in
                        Circle()
                            .fill(index <= currentQuestionIndex ? Color.purple : Color.white.opacity(0.2))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 24)
            }
        }
    }
    
    func checkAnswer(index: Int, correctIndex: Int) {
        showResult = true
        isCorrect = index == correctIndex
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if isCorrect {
                onComplete()
            } else {
                // Move to next question on wrong answer
                currentQuestionIndex = min(currentQuestionIndex + 1, questions.count - 1)
                selectedAnswer = nil
                showResult = false
            }
        }
    }
}

// MARK: - Answer Button
struct AnswerButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool?
    let isWrong: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(buttonColor)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if isCorrect == true {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else if isWrong {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: isSelected ? 2 : 1)
            )
        }
        .disabled(isCorrect != nil)
    }
    
    var buttonColor: Color {
        if let isCorrect = isCorrect {
            return isCorrect ? .green : (isWrong ? .red : .white)
        }
        return isSelected ? .white : .gray
    }
    
    var backgroundColor: Color {
        if let isCorrect = isCorrect {
            return isCorrect ? Color.green.opacity(0.1) : (isWrong ? Color.red.opacity(0.1) : Color.white.opacity(0.05))
        }
        return isSelected ? Color.purple.opacity(0.2) : Color.white.opacity(0.05)
    }
    
    var borderColor: Color {
        if let isCorrect = isCorrect {
            return isCorrect ? .green : (isWrong ? .red : .clear)
        }
        return isSelected ? .purple : .white.opacity(0.2)
    }
}

// MARK: - Scroll Speed Detector
class ScrollSpeedDetector: ObservableObject {
    @Published var scrollSpeed: CGFloat = 0
    @Published var isScrollingFast: Bool = false
    
    private var lastOffset: CGFloat = 0
    private var lastTime: Date = Date()
    
    func updateScroll(offset: CGFloat) {
        let now = Date()
        let timeDelta = now.timeIntervalSince(lastTime)
        
        if timeDelta > 0 {
            let offsetDelta = abs(offset - lastOffset)
            scrollSpeed = offsetDelta / CGFloat(timeDelta)
            
            // Consider "fast scrolling" if speed > 5000 points per second
            isScrollingFast = scrollSpeed > 5000
        }
        
        lastOffset = offset
        lastTime = now
    }
    
    func reset() {
        scrollSpeed = 0
        isScrollingFast = false
    }
}

// MARK: - Focus Shield Overlay
struct FocusShieldOverlay: View {
    @Binding var isPresented: Bool
    let blockedAppName: String
    let onComplete: () -> Void
    let onOverride: () -> Void
    
    @State private var countdown: Int = 10
    @State private var breathPhase: BreathPhase = .inhale
    @State private var breathProgress: Double = 0
    
    enum BreathPhase: String {
        case inhale = "Breathe In"
        case hold = "Hold"
        case exhale = "Breathe Out"
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Icon
                Image(systemName: "bell.slash.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                
                Text("Focus Time")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("You tried to open \(blockedAppName)")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                
                // Breathing exercise
                VStack(spacing: 16) {
                    Text(breathPhase.rawValue)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                    
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 8)
                            .frame(width: 150, height: 150)
                        
                        Circle()
                            .trim(from: 0, to: breathProgress)
                            .stroke(
                                LinearGradient(colors: [.purple, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing),
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .frame(width: 150, height: 150)
                            .rotationEffect(.degrees(-90))
                    }
                    
                    Text("Take a breath before proceeding")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 24)
                
                Spacer()
                
                // Override button
                Button {
                    onOverride()
                } label: {
                    Text("Override Anyway")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                        .padding(.vertical, 12)
                }
                
                // Complete button
                Button {
                    onComplete()
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("I'm Focused")
                    }
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(16)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            startBreathingExercise()
        }
    }
    
    func startBreathingExercise() {
        // 4-4-4 breathing pattern
        let phases: [(BreathPhase, Int)] = [(.inhale, 4), (.hold, 4), (.exhale, 4)]
        var currentPhase = 0
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            let phase = phases[currentPhase % 3]
            breathPhase = phase.0
            breathProgress = Double(phase.1 - (currentPhase % 3 == 0 ? 0 : 1)) / 4.0
            
            currentPhase += 1
            
            if currentPhase >= 12 {
                timer.invalidate()
                breathPhase = .hold
                breathProgress = 1.0
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ScrollStoppingOverlay(
        isPresented: .constant(true),
        onComplete: {},
        onSkip: {},
        skipRemaining: 2
    )
}
