import SwiftUI

/// Entry point for every challenge launch.
///
/// Routes each challenge type to its purpose-built screen where one exists and falls
/// back to the generic `UniversalChallengeView` engine otherwise. Every route reports
/// its score through `record(score:)` so progress, skills, streak and cloud sync are
/// handled in exactly one place.
struct ChallengeView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    let challenge: AllChallengeType

    var body: some View {
        Group {
            if appState.hasHeartsToPlay {
                challengeScreen
            } else {
                OutOfHeartsView()
            }
        }
        .environmentObject(appState)
    }

    @ViewBuilder
    private var challengeScreen: some View {
        switch challenge {
        // Focus - tap the target under time pressure
        case .movingTarget, .focusSprint, .focusEndurance:
            RapidTargetView(onComplete: record)

        // Focus - hold a steady gaze
        case .gazeHold, .focusHold, .stillnessTest:
            GazeHoldView(onComplete: record)

        // Focus - track several objects at once
        case .multiObjectTracking, .slowTracking:
            MultiObjectTrackingView(onComplete: record)

        // Memory - spatial grid recall
        case .memoryFlash, .memoryPuzzle, .patternMatching, .spatialPuzzle, .tapPattern:
            MemoryGridView(onComplete: record)

        // Memory - sequence recall
        case .colorPattern, .numberSequence:
            ColorPatternMemoryView(onComplete: record)

        // Reaction - go/no-go tapping
        case .reactionInhibition, .impulseSpikeTest, .rhythmTap, .delayUnlock:
            LightningTapView(onComplete: record)

        // Discipline - resist the notification bait
        case .fakeNotifications, .notificationResistance, .popupIgnore, .appSwitchResistance:
            FakeNotificationsChallengeView(onComplete: record)

        default:
            if challenge.category == .breathing {
                BreathingExerciseView(onComplete: record)
            } else {
                UniversalChallengeView(challenge: challenge)
            }
        }
    }

    /// Single place where a finished run turns into progress.
    private func record(score: Int) {
        appState.completeChallenge(
            type: challenge,
            score: score,
            xpEarned: challenge.xpReward
        )
    }
}

/// Shown when a player starts a challenge with an empty heart bar.
struct OutOfHeartsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "0A0F1C"), Color(hex: "1E293B")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "heart.slash.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)

                Text("Out of hearts")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)

                Text(appState.nextHeartText)
                    .font(.system(size: 16))
                    .foregroundColor(.gray)

                Button {
                    if appState.purchaseHeartRefill() {
                        AppAudioManager.shared.playReward()
                    } else {
                        AppAudioManager.shared.playInsufficientFunds()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "diamond.fill")
                        Text("Refill for \(AppState.heartRefillCost) gems")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(appState.gemBalance >= AppState.heartRefillCost ? Color.cyan : Color.gray)
                    .cornerRadius(12)
                }
                .disabled(appState.gemBalance < AppState.heartRefillCost)
                .padding(.horizontal, 32)
                .padding(.top, 8)

                Button("Back") { dismiss() }
                    .foregroundColor(.gray)
            }
        }
    }
}
