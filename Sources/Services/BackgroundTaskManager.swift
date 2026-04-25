import Foundation
import os.log
import BackgroundTasks
import UIKit

/// Manages background tasks for app refresh and data sync


class BackgroundTaskManager {
    static let shared = BackgroundTaskManager()
    
    // Background task identifiers
    static let refreshTaskIdentifier = "com.focusflow.app.refresh"
    static let syncTaskIdentifier = "com.focusflow.app.sync"
    
    private var supabaseService: SupabaseService?
    private var currentUserId: String?
    private var progressGetter: (() -> GameProgress?)?
    
    private init() {}
    private static let logger = Logger(subsystem: "com.unscroll.focusflow", category: "BackgroundTaskManager")
    
    /// Set a closure to get current progress for background sync
    func setProgressGetter(_ getter: @escaping () -> GameProgress?) {
        self.progressGetter = getter
    }
    
    /// Configure with Supabase service for sync operations
    func configure(supabaseService: SupabaseService, userId: String) {
        self.supabaseService = supabaseService
        self.currentUserId = userId
    }
    
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
            Self.logger.info("Background app refresh scheduled")
        } catch {
            Self.logger.error("Could not schedule app refresh: \(error.localizedDescription)")
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
            Self.logger.info("Background sync scheduled")
        } catch {
            Self.logger.error("Could not schedule background sync: \(error.localizedDescription)")
        }
    }
    
    /// Handle app refresh task
    private func handleAppRefresh(task: BGAppRefreshTask) {
        // Schedule next refresh
        scheduleAppRefresh()
        
        // Create a task for the refresh
        let refreshTask = Task {
            do {
                // Check for any pending sync operations and fetch latest cloud data
                Self.logger.debug("Running app refresh")
                
                guard let supabase = supabaseService, let userId = currentUserId else {
                    task.setTaskCompleted(success: false)
                    return
                }
                
                // Process any pending offline operations
                await SyncQueue.shared.processQueue(supabaseService: supabase, userId: userId)
                
                // Fetch latest progress from cloud
                do {
                    _ = try await supabase.fetchGameProgress(userId: userId)
                    Self.logger.info("Cloud data refreshed")
                } catch {
                    Self.logger.error("Could not fetch cloud data: \(error.localizedDescription)")
                }
                
                // Fetch latest heart state
                do {
                    _ = try await supabase.fetchHeartState(userId: userId)
                    Self.logger.info("Heart state refreshed")
                } catch {
                    Self.logger.error("Could not fetch heart state: \(error.localizedDescription)")
                }
                
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
                Self.logger.debug("Running background sync")
                
                guard let supabase = supabaseService, let userId = currentUserId else {
                    task.setTaskCompleted(success: false)
                    return
                }
                
                // Process pending operations from SyncQueue
                await SyncQueue.shared.processQueue(supabaseService: supabase, userId: userId)
                
                // Upload latest progress to cloud
                if let progress = progressGetter?() {
                    let progressRecord = GameProgressRecord(
                        userId: userId,
                        level: progress.level,
                        xp: progress.currentLevelXP,
                        totalXp: progress.totalXP,
                        streak: progress.streakDays,
                        longestStreak: progress.streakDays,
                        lastSessionDate: progress.lastActivityDate,
                        streakFreezeUsed: progress.streakFreezeUsed,
                        totalSessionsCompleted: progress.completedChallenges.count,
                        totalChallengesCompleted: progress.completedChallenges.count,
                        updatedAt: Date()
                    )
                    
                    do {
                        try await supabase.upsertGameProgress(progressRecord)
                        Self.logger.info("Progress synced to cloud")
                    } catch {
                        Self.logger.error("Could not sync progress: \(error.localizedDescription)")
                    }
                }
                
                // Upload skill progress
                if let progress = progressGetter?() {
                    do {
                        try await supabase.updateSkillProgress(
                            userId: userId,
                            focusScore: progress.focusScore,
                            impulseControlScore: progress.impulseControlScore,
                            distractionResistanceScore: progress.distractionResistanceScore
                        )
                        Self.logger.info("Skills synced to cloud")
                    } catch {
                        Self.logger.error("Could not sync skills: \(error.localizedDescription)")
                    }
                }
                
                Self.logger.info("Background sync completed")
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
