//
//  NotesUITestsLaunchTests.swift
//  NotesUITests
//
//  Created by VietDH3.AVI on 31/8/25.
//

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
        // Configure app for launch testing
        let app = XCUIApplication()
        app.launchArguments = [
            "-UI_TESTS",
            "-ResetCoreData",
            "-UI_TESTS_DISABLE_ANIMATIONS"
        ]
        
        // Launch the app
        app.launch()
        
        // Wait for app to fully launch
        let expectation = XCTestExpectation(description: "App launched successfully")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            expectation.fulfill()
        }
        
        _ = XCTWaiter.wait(for: [expectation], timeout: 5.0)
        
        // Verify app launched successfully
        XCTAssertTrue(app.exists, "App should exist after launch")
        
        // Verify basic UI elements are present
        let navigationBar = app.navigationBars.firstMatch
        XCTAssertTrue(navigationBar.exists, "Navigation bar should exist after launch")
        
        // Verify app is responsive
        XCTAssertTrue(app.isEnabled, "App should be enabled after launch")
        
        // Take screenshot
        takeScreenshot(name: "App_Launch_Success")
        
        // Terminate app
        app.terminate()
    }
}
