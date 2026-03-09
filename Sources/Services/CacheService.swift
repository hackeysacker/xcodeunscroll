import Foundation
import Network

// MARK: - Offline Cache Service
// Handles local caching for offline functionality

class CacheService {
    static let shared = CacheService()
    
    private let userDefaults = UserDefaults.standard
    private let cacheKeys = CacheKeys.self
    private let queue = DispatchQueue(label: "com.focusflow.cache", qos: .utility)
    
    // Pending sync operations when offline
    @Published private(set) var pendingSyncCount: Int = 0
    
    private init() {
        loadPendingSyncCount()
    }
    
    // MARK: - Cache Keys
    struct CacheKeys {
        static let profile = "cache_profile"
        static let gameProgress = "cache_game_progress"
        static let skillProgress = "cache_skill_progress"
        static let heartState = "cache_heart_state"
        static let badges = "cache_badges"
        static let lastSync = "cache_last_sync"
        static let pendingSyncQueue = "cache_pending_sync"
    }
    
    // MARK: - Profile Cache
    func cacheProfile(_ profile: Profile) {
        save(profile, forKey: CacheKeys.profile)
    }
    
    func getCachedProfile() -> Profile? {
        return load(Profile.self, forKey: CacheKeys.profile)
    }
    
    // MARK: - Game Progress Cache
    func cacheGameProgress(_ progress: GameProgressRecord) {
        save(progress, forKey: CacheKeys.gameProgress)
    }
    
    func getCachedGameProgress() -> GameProgressRecord? {
        return load(GameProgressRecord.self, forKey: CacheKeys.gameProgress)
    }
    
    // MARK: - Skill Progress Cache
    func cacheSkillProgress(_ progress: SkillProgressRecord) {
        save(progress, forKey: CacheKeys.skillProgress)
    }
    
    func getCachedSkillProgress() -> SkillProgressRecord? {
        return load(SkillProgressRecord.self, forKey: CacheKeys.skillProgress)
    }
    
    // MARK: - Heart State Cache
    func cacheHeartState(_ state: HeartStateRecord) {
        save(state, forKey: CacheKeys.heartState)
    }
    
    func getCachedHeartState() -> HeartStateRecord? {
        return load(HeartStateRecord.self, forKey: CacheKeys.heartState)
    }
    
    // MARK: - Last Sync Timestamp
    func updateLastSyncTime() {
        userDefaults.set(Date().timeIntervalSince1970, forKey: CacheKeys.lastSync)
    }
    
    func getLastSyncTime() -> Date? {
        let timestamp = userDefaults.double(forKey: CacheKeys.lastSync)
        return timestamp > 0 ? Date(timeIntervalSince1970: timestamp) : nil
    }
    
    // MARK: - Pending Sync Queue
    // Queue changes made offline to sync when back online
    func queuePendingSync(_ operation: SyncOperation) {
        var queue = loadPendingQueue()
        queue.append(operation)
        save(queue, forKey: CacheKeys.pendingSyncQueue)
        pendingSyncCount = queue.count
    }
    
    func getPendingSyncQueue() -> [SyncOperation] {
        return loadPendingQueue()
    }
    
    func clearPendingSyncQueue() {
        userDefaults.removeObject(forKey: CacheKeys.pendingSyncQueue)
        pendingSyncCount = 0
    }
    
    private func loadPendingSyncCount() -> Int {
        let queue = loadPendingQueue()
        pendingSyncCount = queue.count
        return queue.count
    }
    
    private func loadPendingQueue() -> [SyncOperation] {
        return load([SyncOperation].self, forKey: CacheKeys.pendingSyncQueue) ?? []
    }
    
    // MARK: - Clear All Cache
    func clearAllCache() {
        let keys = [
            CacheKeys.profile,
            CacheKeys.gameProgress,
            CacheKeys.skillProgress,
            CacheKeys.heartState,
            CacheKeys.badges,
            CacheKeys.lastSync,
            CacheKeys.pendingSyncQueue
        ]
        keys.forEach { userDefaults.removeObject(forKey: $0) }
        pendingSyncCount = 0
    }
    
    // MARK: - Generic Save/Load
    private func save<T: Encodable>(_ object: T, forKey key: String) {
        queue.async { [weak self] in
            guard let data = try? JSONEncoder().encode(object) else { return }
            self?.userDefaults.set(data, forKey: key)
        }
    }
    
    private func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}

// MARK: - Sync Operation Model
struct SyncOperation: Codable, Identifiable {
    let id: UUID
    let type: SyncOperationType
    let data: Data
    let timestamp: Date
    var retryCount: Int
    
    init(type: SyncOperationType, data: Data) {
        self.id = UUID()
        self.type = type
        self.data = data
        self.timestamp = Date()
        self.retryCount = 0
    }
}

enum SyncOperationType: String, Codable {
    case updateGems
    case updateProgress
    case updateHearts
    case updateSkillProgress
    case saveChallengeResult
}

// MARK: - Network Monitor
class FocusFlowNetworkMonitor: ObservableObject {
    static let shared = FocusFlowNetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.focusflow.network")
    
    @Published private(set) var isConnected: Bool = true
    @Published private(set) var connectionType: ConnectionType = .unknown
    
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
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
            }
        }
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
    
    private func getConnectionType(_ path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) { return .wifi }
        if path.usesInterfaceType(.cellular) { return .cellular }
        if path.usesInterfaceType(.wiredEthernet) { return .ethernet }
        return .unknown
    }
}
