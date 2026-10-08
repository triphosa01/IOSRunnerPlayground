import XCTest

final class IOSRunnerPlaygroundUITests: XCTestCase {

    func testAccountsExpandedPreferencePersists() {

        let app = XCUIApplication()

        // First launch: reset the preference.
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

        // App should initially be expanded.
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

        // Expand them again.
        toggle.tap()

        XCTAssertEqual(
            toggle.label,
            "Collapse accounts"
        )

        // Collapse once more so that we can test persistence.
        toggle.tap()

        XCTAssertEqual(
            toggle.label,
            "Expand accounts"
        )

        // Terminate the application.
        app.terminate()

        // Remove the reset argument before relaunching.
        app.launchArguments = []

        // Relaunch.
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


    func testStageFilter() {

        let app = XCUIApplication()

        // Start with a clean preference state.
        app.launchArguments = [
            "-UITestResetPreferences"
        ]

        app.launch()

        // The database should initially contain all 1596 species.
        let speciesCount = app.staticTexts[
            "speciesCount"
        ]

        XCTAssertTrue(
            speciesCount.waitForExistence(timeout: 10),
            "Species count was not found"
        )

        XCTAssertEqual(
            speciesCount.label,
            "1596 species"
        )

        // Find the Stage picker.
        let stagePicker = app.buttons[
            "stagePicker"
        ]

        XCTAssertTrue(
            stagePicker.waitForExistence(timeout: 10),
            "Stage picker was not found"
        )

        // Open the picker.
        stagePicker.tap()

        // Select Case.
        let caseOption = app.buttons["Case"]

        XCTAssertTrue(
            caseOption.waitForExistence(timeout: 10),
            "Case option was not found"
        )

        caseOption.tap()

        // The filtered list should contain exactly 160 species.
        XCTAssertEqual(
            speciesCount.label,
            "160 species"
        )
    }
}