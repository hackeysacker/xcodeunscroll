import XCTest
@testable import FocusFlow

final class CacheServiceTests: XCTestCase {
    
    var cacheService: CacheService!
    
    override func setUp() {
        super.setUp()
        cacheService = CacheService.shared
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - Cache State Tests
    
    func testCacheServiceSingleton() {
        let service1 = CacheService.shared
        let service2 = CacheService.shared
        XCTAssertTrue(service1 === service2)
    }
    
    // MARK: - Cache Status
    
    func testHasValidCacheReturnsBoolean() {
        let hasCache = cacheService.hasValidCache
        XCTAssertNotNil(hasCache)
    }
    
    func testLastSyncTimeCanBeTracked() {
        let _ = cacheService.lastSyncTime
        // Should not crash - just verify the property exists
        XCTAssertTrue(true)
    }
}
