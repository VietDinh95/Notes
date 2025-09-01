

import XCTest

class NotesUITestsLaunchTests: XCTestCase {
    
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        // Take screenshot if test failed
        if testRun?.hasSucceeded == false {
            takeScreenshot(name: "Launch_Test_Failed_\(name)")
        }
    }
    
    func testLaunch() throws {
        // Configure app for launch testing with performance optimizations
        let app = XCUIApplication()
        UITestConfiguration.configureAppForUITesting(app)
        
        // Launch the app
        app.launch()
        
        // Wait for app to fully launch using predicate-based wait
        let navigationBar = app.navigationBars.firstMatch
        XCTAssertTrue(navigationBar.waitExists(timeout: UITestConfiguration.Timeouts.long), "Navigation bar should exist after launch")
        
        // Verify app launched successfully
        XCTAssertTrue(app.exists, "App should exist after launch")
        
        // Verify basic UI elements are present
        XCTAssertTrue(navigationBar.exists, "Navigation bar should exist after launch")
        
        // Verify app is responsive
        XCTAssertTrue(app.isEnabled, "App should be enabled after launch")
        
        // Take screenshot
        takeScreenshot(name: "App_Launch_Success")
        
        // Terminate app
        app.terminate()
    }
    
    func testLaunchPerformance() throws {
        // Measure launch performance
        measure(metrics: UITestConfiguration.performanceMetrics) {
            let app = XCUIApplication()
            UITestConfiguration.configureAppForPerformanceTesting(app)
            
            app.launch()
            
            // Wait for app to be ready
            let navigationBar = app.navigationBars.firstMatch
            _ = navigationBar.waitExists(timeout: UITestConfiguration.Timeouts.long)
            
            app.terminate()
        }
    }
}
