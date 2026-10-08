import XCTest

final class IOSRunnerPlaygroundUITests: XCTestCase {

    func testAccountsExpandedPreferencePersists() {

        let app = XCUIApplication()

        // Start with a clean application state.
        app.launchArguments = [
            "-UITestResetPreferences"
        ]

        app.launch()

        let toggle = app.buttons[
            "accountsExpandCollapseButton"
        ]

        XCTAssertTrue(
            toggle.waitForExistence(timeout: 10),
            "Expand/collapse button was not found"
        )

        // The app should initially be expanded.
        XCTAssertEqual(
            toggle.label,
            "Collapse accounts"
        )

        // Collapse the accounts.
        toggle.tap()

        XCTAssertEqual(
            toggle.label,
            "Expand accounts"
        )

        // Terminate the application.
        app.terminate()

        // Relaunch it.
        app.launch()

        let toggleAfterRelaunch = app.buttons[
            "accountsExpandCollapseButton"
        ]

        XCTAssertTrue(
            toggleAfterRelaunch.waitForExistence(timeout: 10),
            "Expand/collapse button was not found after relaunch"
        )

        // The collapsed state should have persisted.
        XCTAssertEqual(
            toggleAfterRelaunch.label,
            "Expand accounts"
        )
    }
}