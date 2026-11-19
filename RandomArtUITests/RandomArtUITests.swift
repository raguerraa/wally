//
//  RandomArtUITests.swift
//  RandomArtUITests
//
//  Smoke coverage for the studio, formulas, and navigation. This test does not save photos.
//

import XCTest

@MainActor
final class RandomArtUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testStudioGenerationAndNavigation() {
        let app = XCUIApplication()
        app.launch()

        let generate = app.buttons["generateWallpaperButton"]
        let save = app.buttons["saveWallpaperButton"]
        waitUntilHittable(generate)
        XCTAssertTrue(save.exists)
        XCTAssertTrue(app.sliders["complexitySlider"].exists)
        XCTAssertTrue(app.buttons["showFormulaButton"].exists)
        XCTAssertFalse(app.buttons["showFormulaButton"].isEnabled)
        capture(app, named: "01-studio-idle")

        // Wait on the rendered preview's accessibility state, not a fixed delay.
        let preview = app.descendants(matching: .any)
            .matching(identifier: "wallpaperCanvas").firstMatch
        XCTAssertTrue(preview.waitForExistence(timeout: 5))
        generate.tap()
        let rendered = XCTNSPredicateExpectation(
            predicate: NSPredicate { object, _ in
                (object as? XCUIElement)?.value as? String == "Generated wallpaper"
            },
            object: preview
        )
        XCTAssertEqual(XCTWaiter.wait(for: [rendered], timeout: 45), .completed)
        waitUntilEnabled(generate)
        XCTAssertTrue(save.isEnabled)
        capture(app, named: "02-studio-generated")


        let formula = app.buttons["showFormulaButton"]
        waitUntilEnabled(formula)
        waitUntilHittable(formula)
        formula.tap()
        let closeFormula = app.buttons["formulaCloseButton"]
        waitUntilHittable(closeFormula)
        XCTAssertTrue(
            app.descendants(matching: .any).matching(identifier: "formulaTitle")
                .firstMatch.exists
        )
        let expression = app.textViews["formulaExpression"]
        XCTAssertTrue(expression.waitForExistence(timeout: 5))
        assertFormulaPrefix("R(x,y) =", in: expression)
        capture(app, named: "02a-wallpaper-formula")
        let channels = app.segmentedControls["formulaChannelPicker"]
        channels.buttons["Green"].tap()
        assertFormulaPrefix("G(x,y) =", in: expression)
        channels.buttons["Blue"].tap()
        assertFormulaPrefix("B(x,y) =", in: expression)
        closeFormula.tap()
        waitUntilHittable(generate)
        XCTAssertEqual(preview.value as? String, "Generated wallpaper")

        let studioMenu = app.buttons["studioMenuButton"]
        waitUntilHittable(studioMenu)
        studioMenu.tap()
        let collectionRoute = app.buttons["menuCollection"]
        waitUntilHittable(collectionRoute)
        capture(app, named: "03-navigation")

        collectionRoute.tap()
        let collection = app.collectionViews["wallpaperCollection"]
        XCTAssertTrue(collection.waitForExistence(timeout: 10))
        let firstWallpaper = collection.cells.firstMatch
        waitUntilHittable(firstWallpaper)
        capture(app, named: "04-collection")

        firstWallpaper.tap()
        let closePreview = app.buttons["downloadCloseButton"]
        waitUntilHittable(closePreview)
        XCTAssertTrue(app.buttons["downloadSaveButton"].exists)
        XCTAssertTrue(
            app.descendants(matching: .any).matching(identifier: "downloadTitle")
                .firstMatch.exists
        )
        capture(app, named: "05-wallpaper-preview")

        closePreview.tap()
        let collectionMenu = app.buttons["collectionMenuButton"]
        waitUntilHittable(collectionMenu)
        collectionMenu.tap()
        let guideRoute = app.buttons["menuHowTo"]
        waitUntilHittable(guideRoute)
        guideRoute.tap()
        let guideMenu = app.buttons["guideMenuButton"]
        waitUntilHittable(guideMenu)
        XCTAssertTrue(
            app.descendants(matching: .any).matching(identifier: "guideTitle")
                .firstMatch.exists
        )
        capture(app, named: "06-guide")

        // Return to the same generated artwork; changing screens must not redraw it.
        guideMenu.tap()
        let studioRoute = app.buttons["menuStudio"]
        waitUntilHittable(studioRoute)
        studioRoute.tap()
        waitUntilHittable(generate)
        XCTAssertEqual(preview.value as? String, "Generated wallpaper")
        XCTAssertTrue(save.isEnabled)
    }


    private func assertFormulaPrefix(
        _ prefix: String, in element: XCUIElement,
        file: StaticString = #file, line: UInt = #line
    ) {
        let updated = XCTNSPredicateExpectation(
            predicate: NSPredicate { object, _ in
                guard let value = (object as? XCUIElement)?.value as? String else { return false }
                return value.hasPrefix(prefix) && value.count > prefix.count
            },
            object: element
        )
        XCTAssertEqual(XCTWaiter.wait(for: [updated], timeout: 5), .completed,
                       file: file, line: line)
    }

    private func waitUntilHittable(
        _ element: XCUIElement, timeout: TimeInterval = 10,
        file: StaticString = #file, line: UInt = #line
    ) {
        XCTAssertTrue(element.waitForExistence(timeout: timeout), file: file, line: line)
        let ready = XCTNSPredicateExpectation(
            predicate: NSPredicate { object, _ in
                (object as? XCUIElement)?.isHittable == true
            },
            object: element
        )
        XCTAssertEqual(XCTWaiter.wait(for: [ready], timeout: timeout), .completed,
                       file: file, line: line)
    }

    private func waitUntilEnabled(
        _ element: XCUIElement, file: StaticString = #file, line: UInt = #line
    ) {
        let enabled = XCTNSPredicateExpectation(
            predicate: NSPredicate { object, _ in
                (object as? XCUIElement)?.isEnabled == true
            },
            object: element
        )
        XCTAssertEqual(XCTWaiter.wait(for: [enabled], timeout: 5), .completed,
                       file: file, line: line)
    }

    private func capture(_ app: XCUIApplication, named name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
