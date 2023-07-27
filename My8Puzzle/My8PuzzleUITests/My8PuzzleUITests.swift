
import XCTest

final class My8PuzzleUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // How the navigation between views work
    func testNavigation() throws {
        let app = XCUIApplication()
        app.launch()
    
        // Check the navigation buttons are exist
        let startBtn = app.buttons["Start"]
        XCTAssertTrue(startBtn.exists)
        let settingsBtn = app.buttons["Settings"]
        XCTAssertTrue(settingsBtn.exists)
        let leaderboardBtn = app.buttons["Leaderboard"]
        XCTAssertTrue(leaderboardBtn.exists)
        let classicBtn = app.buttons["Classic Mode"]
        XCTAssertTrue(classicBtn.exists)
        let pictureBtn = app.buttons["Picture Mode"]
        XCTAssertTrue(pictureBtn.exists)
        let photoBtn = app.buttons["Photo Mode"]
        XCTAssertTrue(photoBtn.exists)
        let backBtn = app.buttons["Back"]
        XCTAssertTrue(backBtn.exists)
        let exitBtn = app.buttons["Exit"]
        XCTAssertTrue(exitBtn.exists)
        let cancelBtn = app.buttons["Cancel"]
        XCTAssertTrue(cancelBtn.exists)
        
        // Check navigation to the start view
        XCTAssertTrue(startBtn.isHittable)
        XCTAssertTrue(settingsBtn.isHittable)
        XCTAssertTrue(leaderboardBtn.isHittable)
        startBtn.tap()
        XCTAssertFalse(startBtn.isHittable)
        XCTAssertFalse(settingsBtn.isHittable)
        XCTAssertFalse(leaderboardBtn.isHittable)

        // Double tap to exit
        classicBtn.tap()
        XCTAssertTrue(exitBtn.isHittable)
        exitBtn.tap()
        XCTAssertTrue(exitBtn.isHittable)
        exitBtn.doubleTap()
        XCTAssertFalse(exitBtn.isHittable)
        // (Actually the second tap is on the confirm version of the exit button)
        
        // Check what happen if double tap on a button
        settingsBtn.doubleTap()
        XCTAssertTrue(app.staticTexts["Settings"].exists)
        // It is notr problem if we tap a button twice too fast
    }
    
    // Go to setting, toggle music, relaunch the app, go to setting, music has changed
    func testDatabase() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Go to settings
        let settingsBtn = app.buttons["Settings"]
        XCTAssertTrue(settingsBtn.exists)
        settingsBtn.tap()
        XCTAssertTrue(app.staticTexts["Settings"].exists)
        
        // Toggle the music
        var musicWasOn = true
        if app.buttons["Music: Off"].exists {
            app.buttons["Music: Off"].tap()
            XCTAssertFalse(app.buttons["Music: Off"].exists)
            XCTAssertTrue(app.buttons["Music: On"].exists)
            musicWasOn = false
        } else {
            app.buttons["Music: On"].tap()
            XCTAssertFalse(app.buttons["Music: On"].exists)
        }
        
        // Terminate the app
        app.terminate()
        // Then launch it again
        app.launch()
        
        // If everithing went well then the music button save the new state
        settingsBtn.tap()
        if musicWasOn {
            XCTAssertTrue(app.buttons["Music: Off"].exists)
            XCTAssertFalse(app.buttons["Music: On"].exists)
        } else {
            XCTAssertTrue(app.buttons["Music: On"].exists)
            XCTAssertFalse(app.buttons["Music: Off"].exists)
        }
        
    }
    
    // Test the board
    func testGame() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Go to the board
        app.buttons["Start"].tap()
        app.buttons["Classic Mode"].tap()
        
        // Use the given labels to access the board and tiles
        let board = app.images["board"]
        let tile1 = app.images["tile1"]
        let tile2 = app.images["tile2"]
        let tile3 = app.images["tile3"]
        let tile4 = app.images["tile4"]
        let tile5 = app.images["tile5"]
        let tile6 = app.images["tile6"]
        let tile7 = app.images["tile7"]
        let tile8 = app.images["tile8"]
        let tile9 = app.images["tile9"]
          
        // It will tap the left top center
        board.tap()
        
        // Tap all tiles
        tile1.tap()
        tile2.tap()
        tile3.tap()
        tile4.tap()
        tile5.tap()
        tile6.tap()
        tile7.tap()
        tile8.tap()
        tile9.tap()
        
        // Test pause button
        XCTAssertTrue(board.isHittable)
        app.buttons["Pause"].tap()
        XCTAssertFalse(board.isHittable)
        app.buttons["Resume"].tap()
        XCTAssertTrue(board.isHittable)
        
        // Rapid tile taps
        tile1.doubleTap()
        tile2.doubleTap()
        tile3.doubleTap()
    }
    
    
}
