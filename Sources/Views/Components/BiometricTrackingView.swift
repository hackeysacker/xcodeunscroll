import SwiftUI

// MARK: - Finger Tracking Manager
class FingerTrackingManager: ObservableObject {
    @Published var touchPoints: [CGPoint] = []
    @Published var averagePressure: CGFloat = 0
    @Published var swipeVelocity: CGPoint = .zero
    @Published var gestureType: DetectedGesture = .none
    @Published var tapCount: Int = 0
    @Published var tapRhythm: [Date] = []
    
    private var lastTouchTime: Date?
    
    enum DetectedGesture: String {
        case none = "None"
        case tap = "Tap"
        case doubleTap = "Double Tap"
        case longPress = "Long Press"
        case swipeUp = "Swipe Up"
        case swipeDown = "Swipe Down"
        case swipeLeft = "Swipe Left"
        case swipeRight = "Swipe Right"
        case pinch = "Pinch"
        case rotation = "Rotation"
    }
    
    func recordTouch(_ location: CGPoint, pressure: CGFloat = 1.0) {
        touchPoints.append(location)
        
        // Keep only last 100 points
        if touchPoints.count > 100 {
            touchPoints.removeFirst()
        }
        
        // Calculate average pressure
        averagePressure = (averagePressure * CGFloat(touchPoints.count - 1) + pressure) / CGFloat(touchPoints.count)
        
        // Record tap rhythm
        let now = Date()
        if let last = lastTouchTime {
            let interval = now.timeIntervalSince(last)
            if interval < 0.3 {
                tapRhythm.append(now)
                tapCount += 1
            }
        }
        lastTouchTime = now
        
        // Clean old tap rhythm
        tapRhythm = tapRhythm.filter { now.timeIntervalSince($0) < 5.0 }
    }
    
    func recordSwipe(velocity: CGPoint) {
        swipeVelocity = velocity
        
        // Determine swipe direction
        if abs(velocity.x) > abs(velocity.y) {
            if velocity.x > 0 {
                gestureType = .swipeRight
            } else {
                gestureType = .swipeLeft
            }
        } else {
            if velocity.y > 0 {
                gestureType = .swipeDown
            } else {
                gestureType = .swipeUp
            }
        }
    }
    
    func clearHistory() {
        touchPoints.removeAll()
        swipeVelocity = .zero
        gestureType = .none
    }
    
    // MARK: - Analytics
    
    func getTouchHeatmap() -> [[Int]] {
        // Create a simple 10x10 grid heatmap
        var heatmap = Array(repeating: Array(repeating: 0, count: 10), count: 10)
        
        for point in touchPoints {
            let x = min(Int(point.x / 40), 9)
            let y = min(Int(point.y / 40), 9)
            if x >= 0 && x < 10 && y >= 0 && y < 10 {
                heatmap[y][x] += 1
            }
        }
        
        return heatmap
    }
    
    func getAverageTapPosition() -> CGPoint? {
        guard !touchPoints.isEmpty else { return nil }
        
        let sumX = touchPoints.reduce(0) { $0 + $1.x }
        let sumY = touchPoints.reduce(0) { $0 + $1.y }
        
        return CGPoint(
            x: sumX / CGFloat(touchPoints.count),
            y: sumY / CGFloat(touchPoints.count)
        )
    }
    
    func getTapRhythmScore() -> Double {
        // Returns consistency score (0-100) based on tap timing
        guard tapRhythm.count > 1 else { return 0 }
        
        var intervals: [TimeInterval] = []
        for i in 1..<tapRhythm.count {
            intervals.append(tapRhythm[i].timeIntervalSince(tapRhythm[i-1]))
        }
        
        let avgInterval = intervals.reduce(0, +) / Double(intervals.count)
        let variance = intervals.reduce(0) { $0 + pow($1 - avgInterval, 2) } / Double(intervals.count)
        
        // Lower variance = higher consistency
        let stdDev = sqrt(variance)
        return max(0, min(100, 100 - stdDev * 100))
    }
}

// MARK: - Eye Tracking Manager (Placeholder for ARKit)
class EyeTrackingManager: ObservableObject {
    @Published var isTracking: Bool = false
    @Published var gazePoint: CGPoint = .zero
    @Published var fixationDuration: TimeInterval = 0
    @Published var blinkRate: Double = 0
    @Published var saccadeCount: Int = 0
    
    private var lastGazePoint: CGPoint?
    private var gazeStartTime: Date?
    private var blinkTimestamps: [Date] = []
    private var saccadeThreshold: CGFloat = 50
    
    func startTracking() {
        isTracking = true
        // In production, this would initialize ARKit face tracking
    }
    
    func stopTracking() {
        isTracking = false
    }
    
    func updateGaze(_ point: CGPoint) {
        // Detect saccade (rapid eye movement)
        if let last = lastGazePoint {
            let distance = hypot(point.x - last.x, point.y - last.y)
            if distance > saccadeThreshold {
                saccadeCount += 1
            }
        }
        
        // Track fixation
        if let start = gazeStartTime {
            fixationDuration = Date().timeIntervalSince(start)
        } else {
            gazeStartTime = Date()
        }
        
        gazePoint = point
        lastGazePoint = point
    }
    
    func recordBlink() {
        let now = Date()
        blinkTimestamps.append(now)
        
        // Keep only last minute of blinks
        blinkTimestamps = blinkTimestamps.filter { now.timeIntervalSince($0) < 60 }
        
        // Calculate blink rate per minute
        blinkRate = Double(blinkTimestamps.count)
    }
    
    // MARK: - Analytics
    
    func getReadingSpeed() -> Double {
        // Estimate based on saccades (rough approximation)
        guard fixationDuration > 0 else { return 0 }
        return Double(saccadeCount) / fixationDuration * 60
    }
    
    func getAttentionScore() -> Double {
        // Score based on fixation duration and blink rate
        // Higher fixation = more focused, but some blinks are healthy
        var score = 50.0
        
        // Add points for good fixation
        if fixationDuration > 2.0 {
            score += 25
        }
        
        // Penalize excessive blinking (>20 per minute = tired)
        if blinkRate > 20 {
            score -= 25
        } else if blinkRate < 10 {
            // Very low blink might indicate strain
            score -= 10
        }
        
        return max(0, min(100, score))
    }
}

// MARK: - Finger Tracking Exercise View
struct FingerTrackingExerciseView: View {
    @StateObject private var fingerManager = FingerTrackingManager()
    @Environment(\.dismiss) var dismiss
    
    @State private var showResults: Bool = false
    @State private var exerciseType: ExerciseType = .tapPrecision
    
    enum ExerciseType: String, CaseIterable {
        case tapPrecision = "Tap Precision"
        case swipeSpeed = "Swipe Speed"
        case patternMemory = "Pattern Memory"
        case pressureSensitivity = "Pressure"
    }
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "0A0F1C"), Color(hex: "1E293B")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark").font(.system(size: 18)).foregroundColor(.white)
                    }
                    Spacer()
                    Text("Finger Training")
                        .font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                    Spacer()
                    Button { showResults.toggle() } label: {
                        Image(systemName: "chart.bar").font(.system(size: 18)).foregroundColor(.white)
                    }
                }
                .padding()
                
                // Exercise type selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(ExerciseType.allCases, id: \.self) { type in
                            Button {
                                exerciseType = type
                            } label: {
                                Text(type.rawValue)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(exerciseType == type ? .white : .gray)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(exerciseType == type ? Color.purple.opacity(0.5) : Color.white.opacity(0.1))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Exercise area
                exerciseArea
                
                // Stats
                liveStats
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    fingerManager.recordTouch(value.location)
                }
        )
    }
    
    var exerciseArea: some View {
        ZStack {
            // Touch point visualization
            ForEach(fingerManager.touchPoints.suffix(20).indices, id: \.self) { index in
                let point = fingerManager.touchPoints[index]
                Circle()
                    .fill(Color.purple.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .position(x: point.x, y: point.y)
            }
            
            // Current touch
            if let last = fingerManager.touchPoints.last {
                Circle()
                    .fill(Color.purple)
                    .frame(width: 60, height: 60)
                    .position(x: last.x, y: last.y)
                    .shadow(color: .purple.opacity(0.5), radius: 20)
            }
            
            // Instructions
            VStack {
                Text(exerciseInstructions)
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(40)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
        )
        .padding(.horizontal)
    }
    
    var exerciseInstructions: String {
        switch exerciseType {
        case .tapPrecision:
            return "Tap the center of the circle as fast as you can"
        case .swipeSpeed:
            return "Swipe in all directions quickly"
        case .patternMemory:
            return "Remember the pattern and repeat it"
        case .pressureSensitivity:
            return "Tap with different pressure levels"
        }
    }
    
    var liveStats: some View {
        HStack(spacing: 16) {
            StatBox(icon: "hand.tap.fill", value: "\(fingerManager.touchPoints.count)", label: "Touches", color: .purple)
            StatBox(icon: "hand.draw.fill", value: fingerManager.gestureType.rawValue, label: "Gesture", color: .blue)
            StatBox(icon: "metronome.fill", value: "\(Int(fingerManager.getTapRhythmScore()))%", label: "Rhythm", color: .green)
        }
        .padding(.horizontal)
    }
}

// MARK: - Eye Tracking Exercise View
struct EyeTrackingExerciseView: View {
    @StateObject private var eyeManager = EyeTrackingManager()
    @Environment(\.dismiss) var dismiss
    
    @State private var showCalibration: Bool = true
    @State private var exerciseType: EyeExerciseType = .focusHold
    
    enum EyeExerciseType: String, CaseIterable {
        case focusHold = "Focus Hold"
        case smoothPursuit = "Smooth Pursuit"
        case peripheral = "Peripheral"
        case blinkRest = "Blink Rest"
    }
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "0A0F1C"), Color(hex: "1E293B")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark").font(.system(size: 18)).foregroundColor(.white)
                    }
                    Spacer()
                    Text("Eye Training")
                        .font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                    Spacer()
                    Button { eyeManager.isTracking.toggle() } label: {
                        Image(systemName: eyeManager.isTracking ? "eye.fill" : "eye.slash.fill")
                            .font(.system(size: 18))
                            .foregroundColor(eyeManager.isTracking ? .green : .red)
                    }
                }
                .padding()
                
                if showCalibration {
                    calibrationView
                } else {
                    exerciseArea
                    liveStats
                }
            }
        }
    }
    
    var calibrationView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "eye.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Eye Tracking Calibration")
                .font(.system(size: 24, weight: .bold)).foregroundColor(.white)
            
            Text("Follow the dot with your eyes.\nKeep your head still.")
                .font(.system(size: 14)).foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button {
                withAnimation {
                    showCalibration = false
                    eyeManager.startTracking()
                }
            } label: {
                Text("Start Calibration")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(16)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    var exerciseArea: some View {
        VStack(spacing: 24) {
            // Exercise type selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(EyeExerciseType.allCases, id: \.self) { type in
                        Button {
                            exerciseType = type
                        } label: {
                            Text(type.rawValue)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(exerciseType == type ? .white : .gray)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(exerciseType == type ? Color.blue.opacity(0.5) : Color.white.opacity(0.1))
                                )
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Tracking visualization
            ZStack {
                // Gaze point
                Circle()
                    .fill(Color.blue.opacity(0.5))
                    .frame(width: 30, height: 30)
                    .position(x: eyeManager.gazePoint.x, y: eyeManager.gazePoint.y)
                    .shadow(color: .blue.opacity(0.5), radius: 15)
                
                // Exercise target
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    .frame(width: 100, height: 100)
                
                if exerciseType == .focusHold {
                    Text("Focus on this point")
                        .font(.system(size: 14)).foregroundColor(.gray)
                        .offset(y: -70)
                }
            }
            .frame(height: 200)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.05))
            )
            .padding(.horizontal)
        }
    }
    
    var liveStats: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                StatBox(icon: "eye.fill", value: String(format: "%.1fs", eyeManager.fixationDuration), label: "Fixation", color: .blue)
                StatBox(icon: "eye.circle", value: "\(Int(eyeManager.blinkRate))/min", label: "Blink Rate", color: .green)
                StatBox(icon: "brain.head.profile", value: "\(Int(eyeManager.getAttentionScore()))%", label: "Attention", color: .purple)
            }
            
            // Privacy notice
            HStack {
                Image(systemName: "lock.shield.fill").font(.system(size: 12)).foregroundColor(.gray)
                Text("Eye tracking data is processed on-device only")
                    .font(.system(size: 11)).foregroundColor(.gray)
            }
            .padding(.top, 8)
        }
        .padding(.horizontal)
    }
}

// MARK: - Preview
#Preview {
    FingerTrackingExerciseView()
}
