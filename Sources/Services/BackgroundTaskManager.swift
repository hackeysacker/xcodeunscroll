import Foundation
import BackgroundTasks
import UIKit

/// Manages background tasks for app refresh and data sync
class BackgroundTaskManager {
    static let shared = BackgroundTaskManager()
    
    // Background task identifiers
    static let refreshTaskIdentifier = "com.focusflow.app.refresh"
    static let syncTaskIdentifier = "com.focusflow.app.sync"
    
    private init() {}
    
    /// Register background tasks with the system
    func registerBackgroundTasks() {
        // Register app refresh task
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.refreshTaskIdentifier,
            using: nil
        ) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        
        // Register background processing task for data sync
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.syncTaskIdentifier,
            using: nil
        ) { task in
            self.handleBackgroundSync(task: task as! BGProcessingTask)
        }
    }
    
    /// Schedule app refresh task
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: Self.refreshTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("✅ Background app refresh scheduled")
        } catch {
            print("❌ Could not schedule app refresh: \(error)")
        }
    }
    
    /// Schedule background sync task
    func scheduleBackgroundSync() {
        let request = BGProcessingTaskRequest(identifier: Self.syncTaskIdentifier)
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60) // 1 hour
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("✅ Background sync scheduled")
        } catch {
            print("❌ Could not schedule background sync: \(error)")
        }
    }
    
    /// Handle app refresh task
    private func handleAppRefresh(task: BGAppRefreshTask) {
        // Schedule next refresh
        scheduleAppRefresh()
        
        // Create a task for the refresh
        let refreshTask = Task {
            do {
                // Check for any pending sync operations
                // This would sync data from cloud if needed
                print("🔄 Running app refresh...")
                
                // Simulate some work
                try await Task.sleep(nanoseconds: 1_000_000_000)
                
                task.setTaskCompleted(success: true)
            } catch {
                task.setTaskCompleted(success: false)
            }
        }
        
        // Handle task expiration
        task.expirationHandler = {
            refreshTask.cancel()
        }
    }
    
    /// Handle background sync task
    private func handleBackgroundSync(task: BGProcessingTask) {
        // Schedule next sync
        scheduleBackgroundSync()
        
        // Create a task for syncing
        let syncTask = Task {
            do {
                // Perform data sync
                print("🔄 Running background sync...")
                
                // This would sync user data to/from cloud
                // For now just simulate work
                try await Task.sleep(nanoseconds: 2_000_000_000)
                
                task.setTaskCompleted(success: true)
            } catch {
                task.setTaskCompleted(success: false)
            }
        }
        
        // Handle task expiration
        task.expirationHandler = {
            syncTask.cancel()
        }
    }
    
    /// Cancel all pending background tasks
    func cancelAllTasks() {
        BGTaskScheduler.shared.cancelAllTaskRequests()
    }
}
