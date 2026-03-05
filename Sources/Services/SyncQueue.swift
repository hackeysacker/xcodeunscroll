import Foundation

/// Queues operations to sync when back online
@MainActor
class SyncQueue: ObservableObject {
    static let shared = SyncQueue()
    
    @Published var pendingOperations: [SyncOperation] = []
    @Published var isSyncing: Bool = false
    
    private let userDefaultsKey = "focusflow_sync_queue"
    
    private init() {
        loadPendingOperations()
    }
    
    /// Add an operation to the queue
    func enqueue(_ operation: SyncOperation) {
        pendingOperations.append(operation)
        savePendingOperations()
    }
    
    /// Process all pending operations
    func processQueue(supabaseService: SupabaseService, userId: String) async {
        guard !pendingOperations.isEmpty else { return }
        guard NetworkMonitor.shared.isConnected else { return }
        
        isSyncing = true
        
        var completedOperations: [UUID] = []
        
        for operation in pendingOperations {
            do {
                try await processOperation(operation, supabaseService: supabaseService, userId: userId)
                completedOperations.append(operation.id)
            } catch {
                print("Failed to sync operation \(operation.id): \(error)")
                // Keep failed operations for retry
            }
        }
        
        // Remove completed operations
        pendingOperations.removeAll { op in
            completedOperations.contains(op.id)
        }
        
        savePendingOperations()
        isSyncing = false
    }
    
    private func processOperation(_ operation: SyncOperation, supabaseService: SupabaseService, userId: String) async throws {
        switch operation.type {
        case .updateGems(let gems):
            try await supabaseService.updateGems(userId: userId, gems: gems)
            
        case .updateProgress(let progress):
            try await supabaseService.upsertGameProgress(progress)
            
        case .updateHearts(let hearts):
            try await supabaseService.updateHeartState(userId: userId, currentHearts: hearts)
            
        case .saveChallengeResult(let result):
            try await supabaseService.saveChallengeResult(
                userId: userId,
                challengeType: result.challengeType,
                score: result.score,
                duration: result.duration,
                xpEarned: result.xpEarned,
                isPerfect: result.isPerfect,
                accuracy: result.accuracy
            )
            
        case .updateSkillProgress(let focus, let impulse, let distraction):
            try await supabaseService.updateSkillProgress(
                userId: userId,
                focusScore: focus,
                impulseControlScore: impulse,
                distractionResistanceScore: distraction
            )
        }
    }
    
    /// Save to UserDefaults
    private func savePendingOperations() {
        if let data = try? JSONEncoder().encode(pendingOperations) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
    
    /// Load from UserDefaults
    private func loadPendingOperations() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let operations = try? JSONDecoder().decode([SyncOperation].self, from: data) {
            pendingOperations = operations
        }
    }
    
    /// Clear all pending operations
    func clearQueue() {
        pendingOperations = []
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
    
    /// Get count of pending operations
    var pendingCount: Int {
        pendingOperations.count
    }
}

/// Represents a sync operation to be performed
struct SyncOperation: Codable, Identifiable {
    let id: UUID
    let type: SyncOperationType
    let createdAt: Date
    
    init(type: SyncOperationType) {
        self.id = UUID()
        self.type = type
        self.createdAt = Date()
    }
}

/// Types of sync operations
enum SyncOperationType: Codable {
    case updateGems(gems: Int)
    case updateProgress(GameProgressRecord)
    case updateHearts(hearts: Int)
    case saveChallengeResult(ChallengeResultData)
    case updateSkillProgress(focus: Int, impulse: Int, distraction: Int)
}

/// Simplified challenge result data for sync
struct ChallengeResultData: Codable {
    let challengeType: String
    let score: Int
    let duration: Int
    let xpEarned: Int
    let isPerfect: Bool
    let accuracy: Double?
}
