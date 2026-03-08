import Foundation
import AVFoundation
import UIKit
import AudioToolbox

// MARK: - Audio/Haptic Manager

@MainActor
class AppAudioManager: ObservableObject {
    static let shared = AppAudioManager()
    
    // Settings
    @Published var soundEnabled: Bool = true
    @Published var hapticEnabled: Bool = true
    
    // Generators
    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let softGenerator = UIImpactFeedbackGenerator(style: .soft)
    private let rigidGenerator = UIImpactFeedbackGenerator(style: .rigid)
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    // Audio
    private var audioPlayer: AVAudioPlayer?
    
    private init() {
        prepareHaptics()
    }
    
    func prepareHaptics() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
        heavyGenerator.prepare()
        softGenerator.prepare()
        rigidGenerator.prepare()
        selectionGenerator.prepare()
        notificationGenerator.prepare()
    }
    
    // MARK: - Haptic Feedback
    
    func lightImpact() {
        guard hapticEnabled else { return }
        lightGenerator.impactOccurred()
    }
    
    func mediumImpact() {
        guard hapticEnabled else { return }
        mediumGenerator.impactOccurred()
    }
    
    func heavyImpact() {
        guard hapticEnabled else { return }
        heavyGenerator.impactOccurred()
    }
    
    func softImpact() {
        guard hapticEnabled else { return }
        softGenerator.impactOccurred()
    }
    
    func rigidImpact() {
        guard hapticEnabled else { return }
        rigidGenerator.impactOccurred()
    }
    
    func selection() {
        guard hapticEnabled else { return }
        selectionGenerator.selectionChanged()
    }
    
    func success() {
        guard hapticEnabled else { return }
        notificationGenerator.notificationOccurred(.success)
    }
    
    func warning() {
        guard hapticEnabled else { return }
        notificationGenerator.notificationOccurred(.warning)
    }
    
    func error() {
        guard hapticEnabled else { return }
        notificationGenerator.notificationOccurred(.error)
    }
    
    // Escalating haptics based on combo
    func comboHaptic(_ combo: Int) {
        guard hapticEnabled else { return }
        
        if combo >= 20 {
            heavyImpact()
        } else if combo >= 15 {
            rigidImpact()
        } else if combo >= 10 {
            mediumImpact()
        } else if combo >= 5 {
            lightImpact()
        } else {
            softImpact()
        }
    }
    
    // MARK: - System Sounds
    
    func playTap() {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(1104) // Tock sound
    }
    
    func playUISelect() {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(1105) // Tink sound
    }
    
    func playSuccess() {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(1025) // Positive sound
        success()
    }
    
    func playError() {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(1053) // Negative sound
        error()
    }
    
    func playWarning() {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(1073) // Warning
        warning()
    }
    
    func playLevelUp() {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(1026) // Level up
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.success()
        }
    }
    
    func playReward() {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(1025)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            AudioServicesPlaySystemSound(1025)
        }
        success()
    }
    
    func playHeartLoss() {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(1053)
        error()
    }
    
    func playHeartGain() {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(1025)
        success()
    }
    
    func playGemEarn() {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(1104)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            AudioServicesPlaySystemSound(1104)
        }
        success()
    }
    
    func playButtonTap() {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(1104)
        lightImpact()
    }
    
    func playChallengeStart() {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(1306) // Sharper start sound
        heavyImpact()
    }
    
    func playChallengeComplete() {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(1025)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            AudioServicesPlaySystemSound(1026)
        }
    }
    
    func playPerfect() {
        guard soundEnabled else { return }
        // Magical success sound
        AudioServicesPlaySystemSound(1025)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            AudioServicesPlaySystemSound(1025)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            AudioServicesPlaySystemSound(1026)
            self?.success()
        }
    }
    
    func playCombo(_ combo: Int) {
        guard soundEnabled else { return }
        
        // Every 5 combo
        if combo % 5 == 0 && combo > 0 {
            comboHaptic(combo)
            if combo >= 15 {
                playPerfect()
            } else if combo >= 10 {
                AudioServicesPlaySystemSound(1025)
            } else {
                AudioServicesPlaySystemSound(1104)
            }
        } else {
            lightImpact()
        }
    }
    
    func playCountdownTick() {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(1103)
        lightImpact()
    }
    
    func playCountdownFinal() {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(1306)
        heavyImpact()
    }
    
    func playAchievement() {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(1026)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            AudioServicesPlaySystemSound(1025)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.success()
        }
    }
    
    func playStreak() {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(1026)
        success()
    }
    
    func playStreakBroken() {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(1053)
        error()
    }
    
    func playPurchase() {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(1304)
        success()
    }
    
    func playInsufficientFunds() {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(1073)
        warning()
    }
}
