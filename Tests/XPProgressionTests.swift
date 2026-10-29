import XCTest
@testable import FocusFlow

/// Regression tests for the XP → level progression math.
///
/// **The bug:** level-up checks compared the *cumulative* `totalXP` against
/// `xpForNextLevel`, which is a per-level **delta**. That made the player
/// over-level, and `currentLevelXP` (totalXP − accumulated) went **negative** —
/// producing negative progress rings and nonsensical "XP to next level" labels.
///
/// The fix routes all level math through `GameProgress`'s canonical helpers:
/// `cumulativeXPRequired(forLevel:)`, `level(forTotalXP:)` and `applyLevelUps()`.
final class XPProgressionTests: XCTestCase {

    // MARK: - The canonical curve

    func testCumulativeXPRequiredMatchesKnownThresholds() {
        // Per-level deltas are 100, 250, 400, 550, … so the cumulative
        // thresholds are 0, 100, 350, 750, 1300, …
        XCTAssertEqual(GameProgress.cumulativeXPRequired(forLevel: 1), 0)
        XCTAssertEqual(GameProgress.cumulativeXPRequired(forLevel: 2), 100)
        XCTAssertEqual(GameProgress.cumulativeXPRequired(forLevel: 3), 350)
        XCTAssertEqual(GameProgress.cumulativeXPRequired(forLevel: 4), 750)
        XCTAssertEqual(GameProgress.cumulativeXPRequired(forLevel: 5), 1300)
    }

    func testCumulativeXPRequiredIsMonotonic() {
        for level in 1..<40 {
            XCTAssertLessThan(
                GameProgress.cumulativeXPRequired(forLevel: level),
                GameProgress.cumulativeXPRequired(forLevel: level + 1),
                "Thresholds must increase at level \(level)"
            )
        }
    }

    func testLevelForTotalXPIsInverseOfCumulativeThreshold() {
        for level in 1..<30 {
            let threshold = GameProgress.cumulativeXPRequired(forLevel: level)
            XCTAssertEqual(
                GameProgress.level(forTotalXP: threshold),
                level,
                "Reaching exactly the threshold for level \(level) should give level \(level)"
            )
            XCTAssertEqual(
                GameProgress.level(forTotalXP: threshold - 1),
                max(1, level - 1),
                "One XP short of level \(level) should not reach level \(level)"
            )
        }
    }

    // MARK: - The regression

    func testCurrentLevelXPIsNeverNegativeWhenLevelingUp() {
        var progress = GameProgress()
        progress.totalXP = 0

        // Walk the progression exactly as AppState.completeChallenge does.
        for _ in 0..<60 {
            progress.totalXP += 100
            progress.applyLevelUps()

            XCTAssertGreaterThanOrEqual(
                progress.currentLevelXP, 0,
                "currentLevelXP went negative at level \(progress.level) "
                + "with totalXP \(progress.totalXP)"
            )
        }
    }

    func testProgressToNextLevelStaysInUnitRange() {
        var progress = GameProgress()

        for _ in 0..<60 {
            progress.totalXP += 100
            progress.applyLevelUps()

            XCTAssertGreaterThanOrEqual(progress.progressToNextLevel, 0)
            XCTAssertLessThanOrEqual(progress.progressToNextLevel, 1.0)
        }
    }

    func testApplyLevelUpsReportsNumberOfLevelsGained() {
        var progress = GameProgress()

        progress.totalXP = 100
        XCTAssertEqual(progress.applyLevelUps(), 1, "100 XP should grant exactly one level")
        XCTAssertEqual(progress.level, 2)

        // Not enough for level 3 (needs 350 cumulative).
        progress.totalXP = 200
        XCTAssertEqual(progress.applyLevelUps(), 0)
        XCTAssertEqual(progress.level, 2)

        // Crossing several thresholds at once reports every level gained.
        // 1000 XP spans the level-4 threshold (750) but not level 5 (1300).
        progress.totalXP = 1000
        XCTAssertEqual(progress.applyLevelUps(), 2, "1000 XP takes level 2 → level 4")
        XCTAssertEqual(progress.level, 4)
    }

    func testApplyLevelUpsNeverDeLevels() {
        var progress = GameProgress()
        progress.level = 10
        progress.totalXP = 0

        XCTAssertEqual(progress.applyLevelUps(), 0)
        XCTAssertEqual(progress.level, 10, "A player must never lose a level")
    }

    func testXpThresholdForNextLevelMatchesCumulativeHelper() {
        for level in 1..<25 {
            var progress = GameProgress()
            progress.level = level
            XCTAssertEqual(
                progress.xpThresholdForNextLevel,
                GameProgress.cumulativeXPRequired(forLevel: level + 1),
                "Threshold mismatch at level \(level)"
            )
        }
    }

    func testCurrentLevelXPRemainingIsConsistent() {
        var progress = GameProgress()
        progress.totalXP = 137

        let expectedLevel = GameProgress.level(forTotalXP: 137)
        progress.applyLevelUps()
        XCTAssertEqual(progress.level, expectedLevel)

        // XP earned within the current level.
        let earnedInLevel = progress.totalXP - GameProgress.cumulativeXPRequired(forLevel: progress.level)
        XCTAssertEqual(progress.currentLevelXP, earnedInLevel)
        XCTAssertLessThanOrEqual(earnedInLevel, progress.xpForNextLevel)
    }
}
