import XCTest
@testable import FocusFlow
import Network

final class NetworkMonitorTests: XCTestCase {
    
    // MARK: - Singleton Test
    
    func testSharedInstanceExists() {
        let instance = NetworkMonitor.shared
        XCTAssertNotNil(instance, "NetworkMonitor.shared should not be nil")
    }
    
    func testSharedInstanceIsSame() {
        let instance1 = NetworkMonitor.shared
        let instance2 = NetworkMonitor.shared
        XCTAssertTrue(instance1 === instance2, "NetworkMonitor should be a singleton")
    }
    
    // MARK: - Initial State Tests
    
    func testInitialConnectionState() {
        let monitor = NetworkMonitor.shared
        // Initial state should be connected (assumes network available)
        // The actual value depends on the machine running the tests
        _ = monitor.isConnected
        _ = monitor.connectionType
    }
    
    // MARK: - Interface Type Tests
    
    func testInterfaceTypeValues() {
        // Verify NWInterface.InterfaceType values exist
        let wifiType: NWInterface.InterfaceType? = .wifi
        let cellularType: NWInterface.InterfaceType? = .cellular
        let ethernetType: NWInterface.InterfaceType? = .wiredEthernet
        
        XCTAssertNotNil(wifiType)
        XCTAssertNotNil(cellularType)
        XCTAssertNotNil(ethernetType)
    }
    
    // MARK: - Path Status Tests
    
    func testPathStatusValues() {
        // Verify NWPath.Status values
        let satisfied: NWPath.Status = .satisfied
        let unsatisfied: NWPath.Status = .unsatisfied
        let requiresConnection: NWPath.Status = .requiresConnection
        
        XCTAssertEqual(satisfied, .satisfied)
        XCTAssertEqual(unsatisfied, .unsatisfied)
        XCTAssertEqual(requiresConnection, .requiresConnection)
    }
    
    // MARK: - Monitor Functionality
    
    func testMonitorCanStartAndStop() {
        let monitor = NetworkMonitor.shared
        
        // Should be able to call startMonitoring without crashing
        // Note: In a real test, we'd want to verify it actually starts
        // but since it's a singleton with its own queue, we just verify it doesn't crash
        monitor.startMonitoring()
        
        // Small delay to allow monitor to start
        Thread.sleep(forTimeInterval: 0.1)
        
        // Should be able to stop without crashing
        monitor.stopMonitoring()
    }
    
    // MARK: - ObservableObject Conformance
    
    func testConformsToObservableObject() {
        let monitor = NetworkMonitor.shared
        XCTAssertTrue(monitor is ObservableObject, "NetworkMonitor should conform to ObservableObject")
    }
    
    // MARK: - Published Properties
    
    func testHasPublishedIsConnected() {
        let monitor = NetworkMonitor.shared
        let mirror = Mirror(reflecting: monitor)
        
        var hasIsConnected = false
        for child in mirror.children {
            if child.label == "isConnected" {
                hasIsConnected = true
                break
            }
        }
        
        XCTAssertTrue(hasIsConnected, "NetworkMonitor should have @Published isConnected property")
    }
    
    func testHasPublishedConnectionType() {
        let monitor = NetworkMonitor.shared
        let mirror = Mirror(reflecting: monitor)
        
        var hasConnectionType = false
        for child in mirror.children {
            if child.label == "connectionType" {
                hasConnectionType = true
                break
            }
        }
        
        XCTAssertTrue(hasConnectionType, "NetworkMonitor should have @Published connectionType property")
    }
}
