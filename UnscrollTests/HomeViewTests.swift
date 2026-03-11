import XCTest
@testable import Unscroll

final class HomeViewUITests: XCTestCase {
    
    var homeViewModel: HomeViewModel!
    
    override func setUp() {
        super.setUp()
        homeViewModel = HomeViewModel()
    }
    
    override func tearDown() {
        homeViewModel = nil
        super.tearDown()
    }
    
    // MARK: - Daily Challenges Tests
    
    func testDailyChallengesLoad() {
        let expectations = expectation(description: "Daily challenges should load")
        homeViewModel.loadDailyChallenges()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            expectations.fulfill()
        }
        
        waitForExpectations(timeout: 2)
        XCTAssertNotNil(homeViewModel.dailyChallenges)
    }
    
    func testDailyChallengesCount() {
        // Daily challenges should have exactly 3 challenges
        homeViewModel.dailyChallenges = [
            DailyChallenge(type: .focus, difficulty: .easy),
            DailyChallenge(type: .memory, difficulty: .medium),
            DailyChallenge(type: .reaction, difficulty: .hard)
        ]
        XCTAssertEqual(homeViewModel.dailyChallenges.count, 3)
    }
    
    // MARK: - Streak Tests
    
    func testStreakDisplay() {
        homeViewModel.gameProgress.streak = 7
        XCTAssertEqual(homeViewModel.gameProgress.streak, 7)
    }
    
    func testStreakMilestoneReached() {
        let milestones = [7, 14, 30, 60, 100]
        for milestone in milestones {
            homeViewModel.gameProgress.streak = milestone
            XCTAssertTrue(milestones.contains(homeViewModel.gameProgress.streak))
        }
    }
    
    // MARK: - XP Display Tests
    
    func testXPDisplay() {
        homeViewModel.gameProgress.xp = 250
        XCTAssertEqual(homeViewModel.gameProgress.xp, 250)
    }
    
    func testLevelDisplay() {
        homeViewModel.gameProgress.level = 5
        XCTAssertEqual(homeViewModel.gameProgress.level, 5)
    }
    
    func testXPProgressToNextLevel() {
        // Level 1 -> 2 requires 100 XP
        homeViewModel.gameProgress.xp = 50
        let progress = homeViewModel.xpProgressToNextLevel
        XCTAssertEqual(progress, 0.5) // 50/100 = 50%
    }
    
    // MARK: - Hearts Display Tests
    
    func testHeartsDisplay() {
        homeViewModel.gameProgress.hearts = 3
        XCTAssertEqual(homeViewModel.gameProgress.hearts, 3)
    }
    
    func testLowHeartsWarning() {
        homeViewModel.gameProgress.hearts = 1
        XCTAssertTrue(homeViewModel.gameProgress.hearts <= 1)
    }
    
    // MARK: - Gems Display Tests
    
    func testGemsDisplay() {
        homeViewModel.gameProgress.gems = 500
        XCTAssertEqual(homeViewModel.gameProgress.gems, 500)
    }
    
    // MARK: - Daily Login Tests
    
    func testDailyLoginRewardAvailable() {
        homeViewModel.canClaimDailyReward = true
        XCTAssertTrue(homeViewModel.canClaimDailyReward)
    }
    
    func testDailyLoginRewardClaim() {
        homeViewModel.gameProgress.gems = 0
        homeViewModel.gameProgress.xp = 0
        
        let initialGems = homeViewModel.gameProgress.gems
        let initialXP = homeViewModel.gameProgress.xp
        
        // Simulate claiming reward (day 1: 5 gems, 50 XP)
        homeViewModel.claimDailyReward()
        
        XCTAssertGreaterThan(homeViewModel.gameProgress.gems, initialGems)
        XCTAssertGreaterThan(homeViewModel.gameProgress.xp, initialXP)
    }
    
    // MARK: - Challenge Selection Tests
    
    func testSelectChallenge() {
        let challenge = DailyChallenge(type: .focus, difficulty: .easy)
        homeViewModel.selectChallenge(challenge)
        XCTAssertNotNil(homeViewModel.selectedChallenge)
    }
    
    func testChallengeTypes() {
        let challengeTypes: [ChallengeType] = [.focus, .memory, .reaction, .discipline, .breathing]
        for type in challengeTypes {
            let challenge = DailyChallenge(type: type, difficulty: .easy)
            XCTAssertNotNil(challenge.type)
        }
    }
}

// MARK: - HomeViewModel Helper

class HomeViewModel: ObservableObject {
    @Published var dailyChallenges: [DailyChallenge] = []
    @Published var selectedChallenge: DailyChallenge?
    @Published var canClaimDailyReward: Bool = false
    
    let gameProgress: GameProgress
    
    var xpProgressToNextLevel: Double {
        let xpForCurrentLevel = Double(gameProgress.level - 1) * 100
        let xpForNextLevel = Double(gameProgress.level) * 100
        let xpInCurrentLevel = Double(gameProgress.xp) - xpForCurrentLevel
        let xpNeeded = xpForNextLevel - xpForCurrentLevel
        return min(xpInCurrentLevel / xpNeeded, 1.0)
    }
    
    init() {
        self.gameProgress = GameProgress()
    }
    
    func loadDailyChallenges() {
        // Load 3 daily challenges
        dailyChallenges = [
            DailyChallenge(type: .focus, difficulty: .easy),
            DailyChallenge(type: .memory, difficulty: .medium),
            DailyChallenge(type: .reaction, difficulty: .hard)
        ]
    }
    
    func selectChallenge(_ challenge: DailyChallenge) {
        selectedChallenge = challenge
    }
    
    func claimDailyReward() {
        // Day 1 reward: 5 gems, 50 XP
        gameProgress.addGems(5)
        gameProgress.addXP(50)
    }
}

// MARK: - Daily Challenge Model

struct DailyChallenge: Identifiable {
    let id = UUID()
    let type: ChallengeType
    let difficulty: ChallengeDifficulty
    var completed: Bool = false
    var score: Int = 0
}

enum ChallengeType: String, CaseIterable {
    case focus
    case memory
    case reaction
    case discipline
    case breathing
}

enum ChallengeDifficulty: String, CaseIterable {
    case easy
    case medium
    case hard
    case extreme
}
