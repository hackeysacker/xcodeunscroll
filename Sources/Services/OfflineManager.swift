import Foundation
import Network
import Combine
import Supabase

// MARK: - Network Monitor
/// Monitors network connectivity for offline mode handling
class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published var isConnected: Bool = true
    @Published var connectionType: ConnectionType = .unknown
    
    enum ConnectionType {
        case wifi
        case cellular
        case wired
        case unknown
    }
    
    private init() {
        startMonitoring()
    }
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.connectionType = self?.getConnectionType(path) ?? .unknown
                
                // Notify app of connectivity change
                if path.status == .satisfied {
                    NotificationCenter.default.post(name: .networkDidBecomeAvailable, object: nil)
                } else {
                    NotificationCenter.default.post(name: .networkDidBecomeUnavailable, object: nil)
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
    
    private func getConnectionType(_ path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .wired
        }
        return .unknown
    }
}

// MARK: - Offline Queue
/// Queues changes when offline and syncs when back online
class OfflineQueue: ObservableObject {
    static let shared = OfflineQueue()
    
    @Published var pendingActions: [PendingAction] = []
    @Published var isSyncing: Bool = false
    
    struct PendingAction: Codable, Identifiable {
        let id: UUID
        let type: ActionType
        let data: Data
        let timestamp: Date
        let retryCount: Int
        
        enum ActionType: String, Codable {
            case progressUpdate
            case gemUpdate
            case challengeComplete
            case heartUpdate
        }
        
        init(type: ActionType, data: Data) {
            self.id = UUID()
            self.type = type
            self.data = data
            self.timestamp = Date()
            self.retryCount = 0
        }
    }
    
    private let userDefaultsKey = "focusflow_offline_queue"
    
    private init() {
        loadPersistedQueue()
    }
    
    // MARK: - Queue Management
    
    func enqueue<T: Encodable>(_ action: PendingAction.ActionType, data: T) {
        guard let encoded = try? JSONEncoder().encode(data) else { return }
        
        let action = PendingAction(type: action, data: encoded)
        pendingActions.append(action)
        persistQueue()
    }
    
    func dequeue(_ action: PendingAction) {
        pendingActions.removeAll { $0.id == action.id }
        persistQueue()
    }
    
    func clear() {
        pendingActions.removeAll()
        persistQueue()
    }
    
    // MARK: - Persistence
    
    private func persistQueue() {
        if let data = try? JSONEncoder().encode(pendingActions) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
    
    private func loadPersistedQueue() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let actions = try? JSONDecoder().decode([PendingAction].self, from: data) {
            pendingActions = actions
        }
    }
    
    // MARK: - Sync
    
    func syncPendingActions(supabase: SupabaseClient?, userId: String) async {
        guard !isSyncing else { return }
        guard !pendingActions.isEmpty else { return }
        guard NetworkMonitor.shared.isConnected else { return }
        
        await MainActor.run { isSyncing = true }
        
        var failedActions: [PendingAction] = []
        
        for action in pendingActions {
            do {
                try await processAction(action, supabase: supabase, userId: userId)
                dequeue(action)
            } catch {
                // Keep failed action for retry (up to 3 attempts)
                if action.retryCount < 3 {
                    var retryAction = action
                    failedActions.append(retryAction)
                } else {
                    // Drop after 3 failed attempts
                    print("Dropping action after 3 failed attempts: \(action.type)")
                }
            }
        }
        
        // Update queue with remaining failed actions
        pendingActions = failedActions
        persistQueue()
        
        await MainActor.run { isSyncing = false }
    }
    
    private func processAction(_ action: PendingAction, supabase: SupabaseClient?, userId: String) async throws {
        guard let supabase = supabase else {
            throw OfflineError.noSupabaseClient
        }
        
        switch action.type {
        case .progressUpdate:
            let progress = try JSONDecoder().decode(GameProgressRecord.self, from: action.data)
            try await supabase
                .from("game_progress")
                .upsert(progress)
                .execute()
            
        case .gemUpdate:
            let gems = try JSONDecoder().decode(GemUpdate.self, from: action.data)
            try await supabase
                .from("profiles")
                .update(["gems": gems.newGemsCount])
                .eq("id", value: userId)
                .execute()
            
        case .challengeComplete:
            let result = try JSONDecoder().decode(ChallengeResultRecord.self, from: action.data)
            try await supabase
                .from("challenge_results")
                .insert(result)
                .execute()
            
        case .heartUpdate:
            let hearts = try JSONDecoder().decode(HeartUpdate.self, from: action.data)
            // Update only the hearts field, using a dictionary to avoid requiring all fields
            try await supabase
                .from("heart_state")
                .update(["current_hearts": hearts.newHeartCount])
                .eq("user_id", value: userId)
                .execute()
        }
    }
}

// MARK: - Helper Types
struct GemUpdate: Codable {
    let newGemsCount: Int
}

struct HeartUpdate: Codable {
    let newHeartCount: Int
}

struct ChallengeResultRecord: Codable {
    let userId: String
    let challengeType: String
    let score: Int
    let xpEarned: Int
    let completedAt: Date
}

enum OfflineError: Error {
    case noSupabaseClient
    case syncFailed
}

// MARK: - Notification Names
extension Notification.Name {
    static let networkDidBecomeAvailable = Notification.Name("networkDidBecomeAvailable")
    static let networkDidBecomeUnavailable = Notification.Name("networkDidBecomeUnavailable")
    static let offlineSyncComplete = Notification.Name("offlineSyncComplete")
}
