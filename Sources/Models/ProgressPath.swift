import Foundation

// MARK: - Progress Path System
// 250 Levels across 10 Realms (25 levels each)

struct ProgressPath {
    static let totalLevels = 250
    static let levelsPerRealm = 25
    static let totalRealms = 10
    
    static func realm(for level: Int) -> ProgressRealm {
        let realmIndex = min((level - 1) / levelsPerRealm, totalRealms - 1)
        return ProgressRealm.allRealms[realmIndex]
    }
    
    static func levelInProgressRealm(for level: Int) -> Int {
        return ((level - 1) % levelsPerRealm) + 1
    }
    
    static func xpRequiredFor(level: Int) -> Int {
        // XP curve: increases progressively
        return level * level * 10
    }
    
    static func totalXpToReach(level: Int) -> Int {
        var total = 0
        for i in 1...level {
            total += xpRequiredFor(level: i)
        }
        return total
    }
}

// MARK: - ProgressRealm
struct ProgressRealm: Identifiable, Codable {
    let id: Int
    let name: String
    let description: String
    let icon: String
    let color: String
    let theme: ProgressRealmTheme
    let levels: ClosedRange<Int>
    let challenges: [ProgressRealmChallenge]
    let bossChallenge: AllChallengeType?
    let rewards: ProgressRealmRewards
    
    struct ProgressRealmTheme: Codable {
        let primary: String
        let secondary: String
        let gradient: [String]
    }
    
    struct ProgressRealmRewards: Codable {
        let gems: Int
        let xp: Int
        let badge: String?
    }
    
    struct ProgressRealmChallenge: Identifiable, Codable {
        let id = UUID()
        let type: AllChallengeType
        let requiredScore: Int
        let isBoss: Bool
    }
}

extension ProgressRealm {
    static let allRealms: [ProgressRealm] = [
        // Realm 1: Beginner - Foundation (Levels 1-25)
        ProgressRealm(
            id: 1,
            name: "Mindful Beginnings",
            description: "Train your focus muscles. Learn the basics of attention control.",
            icon: "brain",
            color: "#4CAF50",
            theme: ProgressRealmTheme(
                primary: "#4CAF50",
                secondary: "#81C784",
                gradient: ["#4CAF50", "#8BC34A"]
            ),
            levels: 1...25,
            challenges: [
                ProgressRealmChallenge(type: .movingTarget, requiredScore: 100, isBoss: false),
                ProgressRealmChallenge(type: .memoryFlash, requiredScore: 80, isBoss: false),
                ProgressRealmChallenge(type: .reactionInhibition, requiredScore: 100, isBoss: false),
                ProgressRealmChallenge(type: .breathingBasics, requiredScore: 50, isBoss: false)
            ],
            bossChallenge: .focusHold,
            rewards: ProgressRealmRewards(gems: 50, xp: 500, badge: "realm1")
        ),
        
        // Realm 2: Focus Fortress (Levels 26-50)
        ProgressRealm(
            id: 2,
            name: "Focus Fortress",
            description: "Build mental strength. Resist distractions with unwavering resolve.",
            icon: "shield.fill",
            color: "#2196F3",
            theme: ProgressRealmTheme(
                primary: "#2196F3",
                secondary: "#64B5F6",
                gradient: ["#2196F3", "#1976D2"]
            ),
            levels: 26...50,
            challenges: [
                ProgressRealmChallenge(type: .movingTarget, requiredScore: 200, isBoss: false),
                ProgressRealmChallenge(type: .antiScrollSwipe, requiredScore: 150, isBoss: false),
                ProgressRealmChallenge(type: .gazeHold, requiredScore: 120, isBoss: false),
                ProgressRealmChallenge(type: .fakeNotifications, requiredScore: 100, isBoss: false)
            ],
            bossChallenge: .multiObjectTracking,
            rewards: ProgressRealmRewards(gems: 100, xp: 1000, badge: "realm2")
        ),
        
        // Realm 3: Memory Palace (Levels 51-75)
        ProgressRealm(
            id: 3,
            name: "Memory Palace",
            description: "Forge an unshakeable memory. Train pattern recognition.",
            icon: "memorychip",
            color: "#9C27B0",
            theme: ProgressRealmTheme(
                primary: "#9C27B0",
                secondary: "#BA68C8",
                gradient: ["#9C27B0", "#7B1FA2"]
            ),
            levels: 51...75,
            challenges: [
                ProgressRealmChallenge(type: .numberSequence, requiredScore: 200, isBoss: false),
                ProgressRealmChallenge(type: .patternMatching, requiredScore: 180, isBoss: false),
                ProgressRealmChallenge(type: .spatialPuzzle, requiredScore: 150, isBoss: false),
                ProgressRealmChallenge(type: .tapPattern, requiredScore: 120, isBoss: false)
            ],
            bossChallenge: .memoryPuzzle,
            rewards: ProgressRealmRewards(gems: 150, xp: 1500, badge: "realm3")
        ),
        
        // Realm 4: Reaction Temple (Levels 76-100)
        ProgressRealm(
            id: 4,
            name: "Reaction Temple",
            description: "Achieve lightning-fast reflexes. Perfect your response time.",
            icon: "bolt.fill",
            color: "#FF9800",
            theme: ProgressRealmTheme(
                primary: "#FF9800",
                secondary: "#FFB74D",
                gradient: ["#FF9800", "#F57C00"]
            ),
            levels: 76...100,
            challenges: [
                ProgressRealmChallenge(type: .reactionInhibition, requiredScore: 300, isBoss: false),
                ProgressRealmChallenge(type: .rhythmTap, requiredScore: 250, isBoss: false),
                ProgressRealmChallenge(type: .delayUnlock, requiredScore: 200, isBoss: false),
                ProgressRealmChallenge(type: .resetChallenge, requiredScore: 180, isBoss: false)
            ],
            bossChallenge: .impulseSpikeTest,
            rewards: ProgressRealmRewards(gems: 200, xp: 2000, badge: "realm4")
        ),
        
        // Realm 5: Discipline Dunes (Levels 101-125)
        ProgressRealm(
            id: 5,
            name: "Discipline Dunes",
            description: "Master self-control. Resist the urge to succumb to distractions.",
            icon: "figure.walk",
            color: "#F44336",
            theme: ProgressRealmTheme(
                primary: "#F44336",
                secondary: "#EF5350",
                gradient: ["#F44336", "#D32F2F"]
            ),
            levels: 101...125,
            challenges: [
                ProgressRealmChallenge(type: .antiScrollSwipe, requiredScore: 300, isBoss: false),
                ProgressRealmChallenge(type: .appSwitchResistance, requiredScore: 250, isBoss: false),
                ProgressRealmChallenge(type: .notificationResistance, requiredScore: 200, isBoss: false),
                ProgressRealmChallenge(type: .fingerHold, requiredScore: 180, isBoss: false)
            ],
            bossChallenge: .impulseDelay,
            rewards: ProgressRealmRewards(gems: 250, xp: 2500, badge: "realm5")
        ),
        
        // Realm 6: Breath Mountain (Levels 126-150)
        ProgressRealm(
            id: 6,
            name: "Breath Mountain",
            description: "Find inner peace. Master the art of controlled breathing.",
            icon: "wind",
            color: "#00BCD4",
            theme: ProgressRealmTheme(
                primary: "#00BCD4",
                secondary: "#4DD0E1",
                gradient: ["#00BCD4", "#0097A7"]
            ),
            levels: 126...150,
            challenges: [
                ProgressRealmChallenge(type: .breathingBasics, requiredScore: 150, isBoss: false),
                ProgressRealmChallenge(type: .calmFocus, requiredScore: 200, isBoss: false),
                ProgressRealmChallenge(type: .stressRelief, requiredScore: 250, isBoss: false),
                ProgressRealmChallenge(type: .energyBoost, requiredScore: 200, isBoss: false)
            ],
            bossChallenge: .deepBreath,
            rewards: ProgressRealmRewards(gems: 300, xp: 3000, badge: "realm6")
        ),
        
        // Realm 7: Focus Fusion (Levels 151-175)
        ProgressRealm(
            id: 7,
            name: "Focus Fusion",
            description: "Combine all skills. Multi-task with precision and clarity.",
            icon: "sparkles",
            color: "#E91E63",
            theme: ProgressRealmTheme(
                primary: "#E91E63",
                secondary: "#F06292",
                gradient: ["#E91E63", "#C2185B"]
            ),
            levels: 151...175,
            challenges: [
                ProgressRealmChallenge(type: .multiObjectTracking, requiredScore: 400, isBoss: false),
                ProgressRealmChallenge(type: .patternMatching, requiredScore: 350, isBoss: false),
                ProgressRealmChallenge(type: .rhythmTap, requiredScore: 300, isBoss: false),
                ProgressRealmChallenge(type: .stillnessTest, requiredScore: 250, isBoss: false)
            ],
            bossChallenge: .slowTracking,
            rewards: ProgressRealmRewards(gems: 350, xp: 3500, badge: "realm7")
        ),
        
        // Realm 8: Mind Mastery (Levels 176-200)
        ProgressRealm(
            id: 8,
            name: "Mind Mastery",
            description: "Ultimate mental training. Push your cognitive limits.",
            icon: "crown.fill",
            color: "#FFD700",
            theme: ProgressRealmTheme(
                primary: "#FFD700",
                secondary: "#FFECB3",
                gradient: ["#FFD700", "#FFC107"]
            ),
            levels: 176...200,
            challenges: [
                ProgressRealmChallenge(type: .gazeHold, requiredScore: 500, isBoss: false),
                ProgressRealmChallenge(type: .spatialPuzzle, requiredScore: 450, isBoss: false),
                ProgressRealmChallenge(type: .distractionLog, requiredScore: 400, isBoss: false),
                ProgressRealmChallenge(type: .deepBreath, requiredScore: 350, isBoss: false)
            ],
            bossChallenge: .focusSprint,
            rewards: ProgressRealmRewards(gems: 400, xp: 4000, badge: "realm8")
        ),
        
        // Realm 9: Zen Master (Levels 201-225)
        ProgressRealm(
            id: 9,
            name: "Zen Master",
            description: "Achieve perfect balance. Total mind-body synchronization.",
            icon: "moon.stars.fill",
            color: "#3F51B5",
            theme: ProgressRealmTheme(
                primary: "#3F51B5",
                secondary: "#7986CB",
                gradient: ["#3F51B5", "#303F9F"]
            ),
            levels: 201...225,
            challenges: [
                ProgressRealmChallenge(type: .stillnessTest, requiredScore: 600, isBoss: false),
                ProgressRealmChallenge(type: .breathingAdvanced, requiredScore: 500, isBoss: false),
                ProgressRealmChallenge(type: .impulseDelay, requiredScore: 450, isBoss: false),
                ProgressRealmChallenge(type: .focusEndurance, requiredScore: 400, isBoss: false)
            ],
            bossChallenge: .meditationMaster,
            rewards: ProgressRealmRewards(gems: 500, xp: 5000, badge: "realm9")
        ),
        
        // Realm 10: Legendary (Levels 226-250)
        ProgressRealm(
            id: 10,
            name: "Legendary Focus",
            description: "Become a legend. Your focus is unmatched. The ultimate mastery.",
            icon: "star.circle.fill",
            color: "#FF00FF",
            theme: ProgressRealmTheme(
                primary: "#FF00FF",
                secondary: "#E040FB",
                gradient: ["#FF00FF", "#AA00FF"]
            ),
            levels: 226...250,
            challenges: [
                ProgressRealmChallenge(type: .focusSprint, requiredScore: 800, isBoss: false),
                ProgressRealmChallenge(type: .memoryPuzzle, requiredScore: 700, isBoss: false),
                ProgressRealmChallenge(type: .reactionInhibition, requiredScore: 600, isBoss: false),
                ProgressRealmChallenge(type: .delayUnlock, requiredScore: 500, isBoss: false)
            ],
            bossChallenge: .focusSprint,
            rewards: ProgressRealmRewards(gems: 1000, xp: 10000, badge: "legend")
        )
    ]
    
    static func realmName(for level: Int) -> String {
        return ProgressPath.realm(for: level).name
    }
    
    static func realmDescription(for level: Int) -> String {
        return ProgressPath.realm(for: level).description
    }
}

// MARK: - Progress Node
struct ProgressNode: Identifiable, Codable {
    let id: String
    let level: Int
    let challenge: AllChallengeType
    let requiredScore: Int
    var isCompleted: Bool
    var isUnlocked: Bool
    var completedAt: Date?
    var bestScore: Int
    
    var stars: Int {
        if bestScore >= Int(Double(requiredScore) * 1.5) { return 3 }
        if bestScore >= requiredScore { return 2 }
        if bestScore >= requiredScore / 2 { return 1 }
        return 0
    }
}

// MARK: - User Progress Path
struct UserProgressPath: Codable {
    var currentLevel: Int
    var currentRealm: Int
    var nodes: [ProgressNode]
    var completedRealms: [Int]
    var totalStars: Int
    var lastPlayedAt: Date?
    
    mutating func initialize(for userId: String) {
        currentLevel = 1
        currentRealm = 1
        nodes = []
        completedRealms = []
        totalStars = 0
        
        // Create all 250 nodes
        for level in 1...250 {
            let realm = ProgressPath.realm(for: level)
            let realmChallenges = realm.challenges
            let challengeIdx = (level - 1) % realmChallenges.count
            let challenge = realmChallenges[challengeIdx]
            
            let node = ProgressNode(
                id: "\(userId)_\(level)",
                level: level,
                challenge: challenge.type,
                requiredScore: challenge.requiredScore,
                isCompleted: false,
                isUnlocked: level == 1,
                completedAt: nil,
                bestScore: 0
            )
            nodes.append(node)
        }
    }
    
    mutating func completeNode(level: Int, score: Int) -> (gems: Int, xp: Int, realmCompleted: Bool) {
        guard level <= nodes.count else { return (0, 0, false) }
        
        let nodeIndex = level - 1
        let node = nodes[nodeIndex]
        
        // Update node
        nodes[nodeIndex].isCompleted = true
        nodes[nodeIndex].completedAt = Date()
        nodes[nodeIndex].bestScore = max(nodes[nodeIndex].bestScore, score)
        
        // Calculate stars
        totalStars += nodes[nodeIndex].stars
        
        // Unlock next level
        if level < 250 {
            nodes[level].isUnlocked = true
        }
        
        // Check realm completion
        var realmCompleted = false
        var realmGems = 0
        var realmXp = 0
        
        let realm = ProgressRealm.allRealms[currentRealm - 1]
        let realmLevels = realm.levels
        let realmEndLevel = realmLevels.upperBound
        
        if level == realmEndLevel {
            // Realm completed!
            completedRealms.append(currentRealm)
            realmGems = realm.rewards.gems
            realmXp = realm.rewards.xp
            realmCompleted = true
            
            // Move to next realm
            if currentRealm < 10 {
                currentRealm += 1
            }
            currentLevel = min(level + 1, 250)
        } else {
            currentLevel = level + 1
        }
        
        lastPlayedAt = Date()
        
        // Base rewards
        let baseGems = score / 10
        let baseXp = score * 2
        
        return (baseGems + realmGems, baseXp + realmXp, realmCompleted)
    }
    
    func isUnlocked(level: Int) -> Bool {
        guard level <= nodes.count else { return false }
        return nodes[level - 1].isUnlocked
    }
    
    func isCompleted(level: Int) -> Bool {
        guard level <= nodes.count else { return false }
        return nodes[level - 1].isCompleted
    }
    
    func stars(for level: Int) -> Int {
        guard level <= nodes.count else { return 0 }
        return nodes[level - 1].stars
    }
}
