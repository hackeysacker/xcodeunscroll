import Foundation
import Combine
import SwiftUI

/// Manages focus timer sessions with countdown, breaks, and tracking
@MainActor
class FocusTimerManager: ObservableObject {
    static let shared = FocusTimerManager()
    
    // Timer state
    @Published var isRunning: Bool = false
    @Published var isPaused: Bool = false
    @Published var currentSessionMinutes: Int = 25  // Default Pomodoro
    @Published var timeRemainingSeconds: Int = 25 * 60
    @Published var elapsedSeconds: Int = 0
    
    // Session tracking
    @Published var currentSession: FocusSession?
    @Published var sessionsCompletedToday: Int = 0
    @Published var totalFocusMinutesToday: Int = 0
    
    // Break state
    @Published var isBreakTime: Bool = false
    @Published var breakMinutes: Int = 5
    @Published var breakTimeRemaining: Int = 5 * 60
    
    // Settings
    @Published var autoStartBreaks: Bool = true
    @Published var longBreakMinutes: Int = 15
    @Published var sessionsBeforeLongBreak: Int = 4
    
    // Timer
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // App state reference
    weak var appState: AppState?
    
    private init() {}
    
    // MARK: - Timer Controls
    
    func startSession(minutes: Int, appState: AppState) {
        self.appState = appState
        currentSessionMinutes = minutes
        timeRemainingSeconds = minutes * 60
        elapsedSeconds = 0
        isRunning = true
        isPaused = false
        isBreakTime = false
        
        // Create new session
        currentSession = FocusSession(targetMinutes: minutes)
        
        startTimer()
        AppAudioManager.shared.playChallengeStart()
    }
    
    func pause() {
        isPaused = true
        timer?.invalidate()
        timer = nil
    }
    
    func resume() {
        isPaused = false
        startTimer()
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isPaused = false
        isBreakTime = false
        
        // Complete session with current progress
        completeSession(completed: false)
    }
    
    func skip() {
        timer?.invalidate()
        timer = nil
        
        if isBreakTime {
            // Skip break and start new session
            isBreakTime = false
            isRunning = true
            timeRemainingSeconds = currentSessionMinutes * 60
            startTimer()
        } else {
            // End session early
            completeSession(completed: false)
        }
    }
    
    // MARK: - Timer Logic
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }
    
    private func tick() {
        guard isRunning && !isPaused else { return }
        
        if isBreakTime {
            breakTimeRemaining -= 1
            elapsedSeconds += 1
            
            if breakTimeRemaining <= 0 {
                endBreak()
            }
        } else {
            timeRemainingSeconds -= 1
            elapsedSeconds += 1
            
            if timeRemainingSeconds <= 0 {
                completeSession(completed: true)
            }
        }
        
        // Haptic feedback at milestones
        if elapsedSeconds % 60 == 0 && elapsedSeconds > 0 {
            AppAudioManager.shared.playCountdownTick()
        }
    }
    
    private func completeSession(completed: Bool) {
        timer?.invalidate()
        timer = nil
        
        guard var session = currentSession else { return }
        
        session.complete()
        
        // Calculate XP and gems based on completion
        let minutesFocused = elapsedSeconds / 60
        let xpEarned = completed ? minutesFocused * 10 : minutesFocused * 5
        let gemsEarned = completed ? max(1, minutesFocused / 10) : 0
        
        session.xpEarned = xpEarned
        session.gemsEarned = gemsEarned
        
        // Update app state
        Task { @MainActor in
            appState?.progress?.totalFocusMinutes += minutesFocused
            appState?.progress?.todayFocusMinutes += minutesFocused
            appState?.progress?.focusSessions.append(session)
            
            // Add XP and gems
            if completed {
                appState?.progress?.totalXP += xpEarned
                appState?.progress?.gems += gemsEarned
                
                // Check for level up
                checkLevelUp()
            }
            
            sessionsCompletedToday += 1
            totalFocusMinutesToday += minutesFocused
        }
        
        // Play completion sound
        if completed {
            AppAudioManager.shared.playChallengeComplete()
        }
        
        // Start break if enabled
        if completed && autoStartBreaks {
            startBreak()
        } else {
            isRunning = false
            currentSession = nil
        }
    }
    
    private func startBreak() {
        isBreakTime = true
        isRunning = true
        
        // Determine break type
        if sessionsCompletedToday > 0 && sessionsCompletedToday % sessionsBeforeLongBreak == 0 {
            breakMinutes = longBreakMinutes
        } else {
            breakMinutes = 5
        }
        breakTimeRemaining = breakMinutes * 60
        
        startTimer()
    }
    
    private func endBreak() {
        timer?.invalidate()
        timer = nil
        isBreakTime = false
        isRunning = false
    }
    
    // MARK: - Level Up
    
    private func checkLevelUp() {
        guard let progress = appState?.progress else { return }
        
        let oldLevel = progress.level
        let newLevel = calculateLevel(from: progress.totalXP)
        
        if newLevel > oldLevel {
            appState?.levelUpFrom = oldLevel
            appState?.progress?.level = newLevel
            appState?.showLevelUpCelebration = true
            AppAudioManager.shared.playLevelUp()
        }
    }
    
    private func calculateLevel(from xp: Int) -> Int {
        var level = 1
        var xpNeeded = 100
        var totalXpForLevel = 0
        
        while totalXpForLevel + xpNeeded <= xp {
            totalXpForLevel += xpNeeded
            level += 1
            xpNeeded = level * 100 + (level - 1) * 50
        }
        
        return level
    }
    
    // MARK: - Reset Daily
    
    func resetDaily() {
        sessionsCompletedToday = 0
        totalFocusMinutesToday = 0
    }
    
    // MARK: - Formatted Time
    
    var formattedTimeRemaining: String {
        let minutes = timeRemainingSeconds / 60
        let seconds = timeRemainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var formattedBreakTimeRemaining: String {
        let minutes = breakTimeRemaining / 60
        let seconds = breakTimeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var progress: Double {
        guard currentSessionMinutes > 0 else { return 0 }
        return 1.0 - (Double(timeRemainingSeconds) / Double(currentSessionMinutes * 60))
    }
    
    var breakProgress: Double {
        guard breakMinutes > 0 else { return 0 }
        return 1.0 - (Double(breakTimeRemaining) / Double(breakMinutes * 60))
    }
}
