import Foundation
import CoreData
import UIKit

/// Configuration and setup for NotesKit framework integration
struct NotesKitConfig {
    
    // MARK: - Configuration Keys
    
    static let useCloudKitKey = "UseCloudKitSync"
    static let cloudKitContainerIdentifier = "iCloud.ios-assignment.Notes"
    static let enableAnimationsKey = "EnableEnhancedAnimations"
    static let enableStatisticsKey = "EnableNoteStatistics"
    
    // MARK: - Default Settings
    
    static var useCloudKit: Bool {
        get {
            UserDefaults.standard.bool(forKey: useCloudKitKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: useCloudKitKey)
        }
    }
    
    static var enableAnimations: Bool {
        get {
            UserDefaults.standard.bool(forKey: enableAnimationsKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: enableAnimationsKey)
        }
    }
    
    static var enableStatistics: Bool {
        get {
            UserDefaults.standard.bool(forKey: enableStatisticsKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: enableStatisticsKey)
        }
    }
    
    // MARK: - CloudKit Configuration
    
    /// Get CloudKit container identifier
    static func getCloudKitContainerIdentifier() -> String {
        // In production, this should come from your app's entitlements
        return cloudKitContainerIdentifier
    }
    
    /// Check if CloudKit is available and properly configured
    static func isCloudKitAvailable() -> Bool {
        // Check if iCloud is enabled
        guard FileManager.default.ubiquityIdentityToken != nil else {
            return false
        }
        
        // Check if CloudKit container is accessible
        // This is a simplified check - in production you'd want more robust validation
        return true
    }
    
    // MARK: - Animation Configuration
    
    /// Get animation duration based on user preferences
    static func getAnimationDuration() -> Double {
        return enableAnimations ? 0.3 : 0.0
    }
    
    /// Check if animations should be reduced (accessibility)
    static func shouldReduceAnimations() -> Bool {
        return UIAccessibility.isReduceMotionEnabled
    }
    
    // MARK: - Statistics Configuration
    
    /// Check if statistics collection is enabled
    static func isStatisticsEnabled() -> Bool {
        return enableStatistics && !UIAccessibility.isReduceMotionEnabled
    }
    
    // MARK: - Performance Configuration
    
    /// Get batch size for Core Data operations
    static func getBatchSize() -> Int {
        return 50 // Optimal batch size for most operations
    }
    
    /// Get fetch limit for search operations
    static func getSearchFetchLimit() -> Int {
        return 100 // Limit search results for performance
    }
    
    // MARK: - Error Handling Configuration
    
    /// Get retry count for failed operations
    static func getRetryCount() -> Int {
        return 3 // Number of retries for failed operations
    }
    
    /// Get timeout for network operations
    static func getNetworkTimeout() -> TimeInterval {
        return 30.0 // 30 seconds timeout
    }
    
    // MARK: - Debug Configuration
    
    /// Check if debug logging is enabled
    static var debugLoggingEnabled: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    /// Log configuration values (debug only)
    static func logConfiguration() {
        guard debugLoggingEnabled else { return }
        
        print("=== NotesKit Configuration ===")
        print("CloudKit Enabled: \(useCloudKit)")
        print("Animations Enabled: \(enableAnimations)")
        print("Statistics Enabled: \(enableStatistics)")
        print("CloudKit Available: \(isCloudKitAvailable())")
        print("Reduce Motion: \(shouldReduceAnimations())")
        print("===============================")
    }
}

// MARK: - Migration Support

extension NotesKitConfig {
    
    /// Check if migration is needed
    static func needsMigration() -> Bool {
        // Check app version and determine if migration is needed
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let lastVersion = UserDefaults.standard.string(forKey: "LastAppVersion") ?? "1.0"
        
        return currentVersion != lastVersion
    }
    
    /// Mark migration as complete
    static func markMigrationComplete() {
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        UserDefaults.standard.set(currentVersion, forKey: "LastAppVersion")
    }
}

// MARK: - Feature Flags

extension NotesKitConfig {
    
    /// Check if a specific feature is enabled
    static func isFeatureEnabled(_ feature: FeatureFlag) -> Bool {
        switch feature {
        case .cloudKitSync:
            return useCloudKit && isCloudKitAvailable()
        case .enhancedAnimations:
            return enableAnimations && !shouldReduceAnimations()
        case .noteStatistics:
            return enableStatistics
        case .advancedSearch:
            return true // Always enabled for now
        case .noteSharing:
            return useCloudKit && isCloudKitAvailable()
        }
    }
}

/// Available feature flags
enum FeatureFlag {
    case cloudKitSync
    case enhancedAnimations
    case noteStatistics
    case advancedSearch
    case noteSharing
}
