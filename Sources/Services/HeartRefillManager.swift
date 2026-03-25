import Foundation
import Combine

// MARK: - Heart Refill Manager
// Manages heart refill slots and over-time heart regeneration

@MainActor
class HeartRefillManager: ObservableObject {
    static let shared = HeartRefillManager()
    
    // Heart configuration
    let maxHearts: Int = 5
    let maxRefillSlots: Int = 3
    let refillTimeMinutes: Int = 30 // Time to earn one refill slot
    
    // Published state
    @Published var hearts: Int = 5
    @Published var refillSlots: Int = 3
    @Published var nextRefillTime: Date?
    @Published var isTimerRunning: Bool = false
    
    private var refillTimer: Timer?
    private var slotTimer: Timer?
    
    // UserDefaults keys
    private let heartsKey = "heart_refill_hearts"
    private let slotsKey = "heart_refill_slots"
    private let nextRefillKey = "heart_refill_next"
    private let lastUpdateKey = "heart_refill_last_update"
    
    private init() {
        loadState()
        startTimers()
    }
    
    // MARK: - Persistence
    
    func loadState() {
        hearts = UserDefaults.standard.integer(forKey: heartsKey)
        if hearts == 0 { hearts = maxHearts } // Default to full
        
        refillSlots = UserDefaults.standard.integer(forKey: slotsKey)
        if refillSlots == 0 { refillSlots = maxRefillSlots }
        
        if let nextRefill = UserDefaults.standard.object(forKey: nextRefillKey) as? Date {
            nextRefillTime = nextRefill
        }
        
        // Check for missed time while app was closed
        checkMissedTime()
    }
    
    func saveState() {
        UserDefaults.standard.set(hearts, forKey: heartsKey)
        UserDefaults.standard.set(refillSlots, forKey: slotsKey)
        UserDefaults.standard.set(nextRefillTime, forKey: nextRefillKey)
    }
    
    // MARK: - Timers
    
    func startTimers() {
        // Heart slot timer - earn a new slot every 30 minutes
        slotTimer?.invalidate()
        slotTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(refillTimeMinutes * 60), repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.earnRefillSlot()
            }
        }
        
        // Heart regeneration timer - add heart if slots available
        refillTimer?.invalidate()
        refillTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
        
        isTimerRunning = true
    }
    
    func stopTimers() {
        slotTimer?.invalidate()
        refillTimer?.invalidate()
        isTimerRunning = false
    }
    
    // MARK: - Logic
    
    func tick() {
        // Check if we should add a heart
        guard let nextRefill = nextRefillTime, Date() >= nextRefill else { return }
        
        if hearts < maxHearts && refillSlots > 0 {
            hearts += 1
            refillSlots -= 1
            
            // Schedule next heart if we still have slots
            if refillSlots > 0 {
                nextRefillTime = Date().addingTimeInterval(TimeInterval(refillTimeMinutes * 60))
            } else {
                nextRefillTime = nil
            }
            
            saveState()
        }
    }
    
    func earnRefillSlot() {
        guard refillSlots < maxRefillSlots else { return }
        
        refillSlots += 1
        
        // If we have a heart missing and now have a slot, start refill
        if hearts < maxHearts && nextRefillTime == nil {
            nextRefillTime = Date().addingTimeInterval(TimeInterval(refillTimeMinutes * 60))
        }
        
        saveState()
    }
    
    func checkMissedTime() {
        // Calculate how many refill slots we earned while app was closed
        guard let lastUpdate = UserDefaults.standard.object(forKey: lastUpdateKey) as? Date else {
            UserDefaults.standard.set(Date(), forKey: lastUpdateKey)
            return
        }
        
        let minutesPassed = Int(Date().timeIntervalSince(lastUpdate) / 60)
        let slotsEarned = minutesPassed / refillTimeMinutes
        
        if slotsEarned > 0 {
            let newSlots = min(refillSlots + slotsEarned, maxRefillSlots)
            let slotsDiff = newSlots - refillSlots
            refillSlots = newSlots
            
            // Refill hearts based on earned slots
            let heartsToAdd = min(slotsDiff, maxHearts - hearts)
            hearts = min(hearts + heartsToAdd, maxHearts)
            
            // Update next refill time
            if hearts < maxHearts && refillSlots > 0 {
                let remainingMinutes = minutesPassed % refillTimeMinutes
                nextRefillTime = Date().addingTimeInterval(TimeInterval((refillTimeMinutes - remainingMinutes) * 60))
            }
        }
        
        UserDefaults.standard.set(Date(), forKey: lastUpdateKey)
        saveState()
    }
    
    // MARK: - Actions
    
    func useHeart() -> Bool {
        guard hearts > 0 else { return false }
        hearts -= 1
        saveState()
        
        // Start refill if we have slots available
        if refillSlots > 0 && hearts < maxHearts && nextRefillTime == nil {
            nextRefillTime = Date().addingTimeInterval(TimeInterval(refillTimeMinutes * 60))
        }
        
        return true
    }
    
    func addHeart() {
        guard hearts < maxHearts else { return }
        hearts += 1
        saveState()
    }
    
    func refillAllHearts() {
        hearts = maxHearts
        saveState()
    }
    
    // MARK: - Gem Purchase
    
    func purchaseHeartWithGems(cost: Int, appState: AppState) -> Bool {
        guard hearts < maxHearts else { return false }
        guard appState.spendGems(cost) else { return false }
        
        hearts += 1
        saveState()
        return true
    }
    
    func purchaseRefillSlotWithGems(cost: Int, appState: AppState) -> Bool {
        guard refillSlots < maxRefillSlots else { return false }
        guard appState.spendGems(cost) else { return false }
        
        refillSlots += 1
        saveState()
        return true
    }
    
    // MARK: - Display
    
    var nextRefillText: String {
        guard let nextRefill = nextRefillTime else {
            return refillSlots < maxRefillSlots ? "Slot in \(refillTimeMinutes)m" : "All slots full"
        }
        
        let minutes = Int(nextRefill.timeIntervalSinceNow / 60)
        if minutes <= 0 {
            return "Heart soon!"
        }
        return "Heart in \(minutes)m"
    }
    
    var heartsDisplay: String {
        String(repeating: "❤️", count: hearts) + String(repeating: "🖤", count: maxHearts - hearts)
    }
    
    var refillSlotsDisplay: String {
        "Slots: \(refillSlots)/\(maxRefillSlots)"
    }
}
