import XCTest
import UIKit
@testable import RandomArt

final class RandomArtTests: XCTestCase {
    func testGeneratedExpressionsStayInRGBRange() {
        for depth in [1, 2, 4, 7, 11] {
            let tree = MathBinaryTree(depth: depth)
            for x in stride(from: Float(0), through: 1, by: 0.2) {
                for y in stride(from: Float(0), through: 1, by: 0.2) {
                    let value = tree.evaluateTreeFunction(x: x, y: y)
                    XCTAssertTrue(value.isFinite)
                    XCTAssertGreaterThanOrEqual(value, 0)
                    XCTAssertLessThanOrEqual(value, 1)
                }
            }
        }
    }

    func testExportUsesIndependentResolution() {
        let canvas = CanvasV(frame: CGRect(x: 0, y: 0, width: 120, height: 40))
        canvas.changeDepth(with: 2)

        let previewReady = expectation(description: "Preview is drawn")
        canvas.generateWallpaper { success in
            XCTAssertTrue(success)
            previewReady.fulfill()
        }
        wait(for: [previewReady], timeout: 30)

        let exportReady = expectation(description: "High resolution render")
        canvas.exportWallpaper { image in
            XCTAssertEqual(image?.cgImage?.width, 1170)
            XCTAssertEqual(image?.cgImage?.height, 390)
            exportReady.fulfill()
        }
        wait(for: [exportReady], timeout: 60)
    }
}


// These tests control asynchronous completions to reproduce rapid taps reliably.
// They never render a large image or write anything to the user's photo library.
@MainActor
final class CanvasBusyStateTests: XCTestCase {
    private struct Fixture {
        let controller: CanvasVC
        let canvas: ControlledCanvas
        let saver: ControlledPhotoSaver
        let generateButton: UIButton
        let formulaButton: UIButton
    }

    private func makeFixture() throws -> Fixture {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: CanvasVC.self))
        let controller = try XCTUnwrap(
            storyboard.instantiateViewController(withIdentifier: "canvas") as? CanvasVC
        )
        controller.loadViewIfNeeded()

        // Instantiating the real screen also verifies the Save action is connected.
        let saveButton = try XCTUnwrap(controller.saveButton)
        XCTAssertTrue(
            saveButton.actions(forTarget: controller, forControlEvent: .touchUpInside)?
                .contains("saveWallpaper:") == true
        )
        let generateButton = try XCTUnwrap(
            findButton(in: controller.view, identifier: "generateWallpaperButton")
        )

        let formulaButton = try XCTUnwrap(
            findButton(in: controller.view, identifier: "showFormulaButton")
        )

        let canvas = ControlledCanvas(frame: CGRect(x: 0, y: 0, width: 120, height: 40))
        controller.view.addSubview(canvas)
        controller.canvas = canvas
        let saver = ControlledPhotoSaver()
        controller.photoLibrarySaver = saver
        return Fixture(controller: controller, canvas: canvas, saver: saver,
                       generateButton: generateButton, formulaButton: formulaButton)
    }

    private func findButton(in view: UIView, identifier: String) -> UIButton? {
        if let button = view as? UIButton, button.accessibilityIdentifier == identifier {
            return button
        }
        for subview in view.subviews {
            if let button = findButton(in: subview, identifier: identifier) {
                return button
            }
        }
        return nil
    }

    private func assertBusy(
        _ busy: Bool, _ fixture: Fixture, file: StaticString = #file, line: UInt = #line
    ) {
        XCTAssertEqual(fixture.generateButton.isEnabled, !busy, file: file, line: line)
        XCTAssertEqual(fixture.controller.saveButton.isEnabled, !busy, file: file, line: line)
        XCTAssertEqual(fixture.controller.slider.isEnabled, !busy, file: file, line: line)
        XCTAssertEqual(fixture.controller.progressView.isAnimating, busy, file: file, line: line)
        XCTAssertEqual(fixture.formulaButton.isEnabled,
                       !busy && fixture.canvas.currentFormulas != nil, file: file, line: line)
    }

    private func finishPhotoSave(_ fixture: Fixture, error: Error? = nil) {
        fixture.saver.finish(error: error)
        let callbackHandled = expectation(description: "Photos completion reached the main queue")
        DispatchQueue.main.async { callbackHandled.fulfill() }
        wait(for: [callbackHandled], timeout: 2)
    }

    func testGenerateRejectsRepeatedTapsAndSaveUntilPreviewCompletes() throws {
        let fixture = try makeFixture()
        assertBusy(false, fixture)

        fixture.generateButton.sendActions(for: .touchUpInside)
        assertBusy(true, fixture)
        // Direct calls exercise the guard even if an action was already queued.
        fixture.controller.goButtonPressed()
        fixture.controller.saveWallpaper(fixture.controller.saveButton as Any)
        XCTAssertEqual(fixture.canvas.generateCount, 1)
        XCTAssertEqual(fixture.canvas.exportCount, 0)

        fixture.canvas.finishGeneration(success: true)
        assertBusy(false, fixture)
        fixture.controller.goButtonPressed()
        fixture.controller.goButtonPressed()
        XCTAssertEqual(fixture.canvas.generateCount, 2)
        fixture.canvas.finishGeneration(success: true)
        assertBusy(false, fixture)
    }

    func testSaveRejectsRepeatedAndGenerateTapsThroughExportAndPhotosWrite() throws {
        let fixture = try makeFixture()
        fixture.controller.saveButton.sendActions(for: .touchUpInside)
        assertBusy(true, fixture)

        fixture.controller.saveWallpaper(fixture.controller.saveButton as Any)
        fixture.controller.goButtonPressed()
        XCTAssertEqual(fixture.canvas.exportCount, 1)
        XCTAssertEqual(fixture.canvas.generateCount, 0)

        fixture.canvas.finishExport(image: UIImage())
        XCTAssertEqual(fixture.saver.saveCount, 1)
        assertBusy(true, fixture) // Export done; Photos is still writing.

        fixture.controller.saveWallpaper(fixture.controller.saveButton as Any)
        fixture.controller.goButtonPressed()
        XCTAssertEqual(fixture.canvas.exportCount, 1)
        XCTAssertEqual(fixture.canvas.generateCount, 0)
        XCTAssertEqual(fixture.saver.saveCount, 1)

        finishPhotoSave(fixture)
        assertBusy(false, fixture)
        fixture.controller.goButtonPressed()
        XCTAssertEqual(fixture.canvas.generateCount, 1)
        fixture.canvas.finishGeneration(success: true)
    }

    func testFailedPreviewRestoresControlsAndAllowsRetry() throws {
        let fixture = try makeFixture()
        fixture.controller.goButtonPressed()
        fixture.canvas.finishGeneration(success: false)
        assertBusy(false, fixture)

        fixture.controller.goButtonPressed()
        XCTAssertEqual(fixture.canvas.generateCount, 2)
        assertBusy(true, fixture)
        fixture.canvas.finishGeneration(success: true)
        assertBusy(false, fixture)
    }

    func testMissingExportImageRestoresControlsWithoutWritingToPhotos() throws {
        let fixture = try makeFixture()
        fixture.controller.saveWallpaper(fixture.controller.saveButton as Any)
        fixture.canvas.finishExport(image: nil)
        assertBusy(false, fixture)
        XCTAssertEqual(fixture.saver.saveCount, 0)

        fixture.controller.goButtonPressed()
        XCTAssertEqual(fixture.canvas.generateCount, 1)
        fixture.canvas.finishGeneration(success: true)
    }

    func testPhotosFailureRestoresControlsAndAllowsAnotherSave() throws {
        let fixture = try makeFixture()
        fixture.controller.saveWallpaper(fixture.controller.saveButton as Any)
        fixture.canvas.finishExport(image: UIImage())
        assertBusy(true, fixture)

        finishPhotoSave(fixture, error: NSError(domain: "PhotoSaveTest", code: 1))
        assertBusy(false, fixture)
        fixture.controller.saveWallpaper(fixture.controller.saveButton as Any)
        fixture.controller.saveWallpaper(fixture.controller.saveButton as Any)
        XCTAssertEqual(fixture.canvas.exportCount, 2)
        fixture.canvas.finishExport(image: nil)
        assertBusy(false, fixture)
    }

    func testComplexityCannotChangeDuringWork() throws {
        let fixture = try makeFixture()
        fixture.controller.goButtonPressed()
        fixture.controller.changeComplexity(fixture.controller.slider as Any)
        XCTAssertEqual(fixture.canvas.depthChanges, 0)

        fixture.canvas.finishGeneration(success: true)
        fixture.controller.changeComplexity(fixture.controller.slider as Any)
        XCTAssertEqual(fixture.canvas.depthChanges, 1)
    }


    func testFormulaButtonWaitsForWallpaperAndLocksThroughoutWork() throws {
        let fixture = try makeFixture()
        XCTAssertFalse(fixture.formulaButton.isEnabled)

        fixture.controller.goButtonPressed()
        assertBusy(true, fixture)
        fixture.canvas.formulas = WallpaperFormulas(
            red: "x", green: "y", blue: "(x × y)", depth: 1, definitions: []
        )
        // A snapshot alone must not unlock the button while rendering is still in progress.
        XCTAssertFalse(fixture.formulaButton.isEnabled)
        fixture.canvas.finishGeneration(success: true)
        assertBusy(false, fixture)
        XCTAssertTrue(fixture.formulaButton.isEnabled)

        fixture.controller.saveWallpaper(fixture.controller.saveButton as Any)
        assertBusy(true, fixture)
        fixture.canvas.finishExport(image: UIImage())
        assertBusy(true, fixture)
        finishPhotoSave(fixture)
        assertBusy(false, fixture)
        XCTAssertTrue(fixture.formulaButton.isEnabled)

        fixture.controller.goButtonPressed()
        assertBusy(true, fixture)
        fixture.canvas.finishGeneration(success: false)
        assertBusy(false, fixture)
        XCTAssertTrue(fixture.formulaButton.isEnabled)
    }

    func testPhotoSaveCompletionReturnsToMainThread() {
        let controller = UIViewController()
        let saver = ControlledPhotoSaver()
        let completed = expectation(description: "Main-thread Photos completion")
        controller.saveImage(image: UIImage(), using: saver) {
            XCTAssertTrue(Thread.isMainThread)
            completed.fulfill()
        }
        DispatchQueue.global().async {
            saver.finish(error: NSError(domain: "PhotoSaveTest", code: 2))
        }
        wait(for: [completed], timeout: 2)
    }
}

private final class ControlledCanvas: CanvasV {
    var formulas: WallpaperFormulas?
    override var currentFormulas: WallpaperFormulas? { formulas }

    private(set) var generateCount = 0
    private(set) var exportCount = 0
    private(set) var depthChanges = 0
    private var generationCompletion: ((Bool) -> Void)?
    private var exportCompletion: ((UIImage?) -> Void)?

    override func generateWallpaper(completion: @escaping (Bool) -> Void) {
        generateCount += 1
        generationCompletion = completion
    }

    override func exportWallpaper(completion: @escaping (UIImage?) -> Void) {
        exportCount += 1
        exportCompletion = completion
    }

    override func changeDepth(with depth: Int) {
        depthChanges += 1
    }

    func finishGeneration(success: Bool) {
        let completion = generationCompletion
        generationCompletion = nil
        completion?(success)
    }

    func finishExport(image: UIImage?) {
        let completion = exportCompletion
        exportCompletion = nil
        completion?(image)
    }
}

// This fake also completes from a background queue. Protect every mutable
// field while handing the callback between threads, then invoke it unlocked.
private final class ControlledPhotoSaver: PhotoLibrarySaving, @unchecked Sendable {
    private let lock = NSLock()
    private var requestedSaves = 0
    private var completion: ((Error?) -> Void)?

    var saveCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return requestedSaves
    }

    func save(_ image: UIImage, completion: @escaping (Error?) -> Void) {
        lock.lock()
        requestedSaves += 1
        self.completion = completion
        lock.unlock()
    }

    func finish(error: Error? = nil) {
        lock.lock()
        let callback = completion
        completion = nil
        lock.unlock()
        callback?(error)
    }
}

// The displayed formulas must preserve grouping and the renderer's normalization.
final class MathFormulaDescriptionTests: XCTestCase {
    func testNestedFormulaPreservesArithmeticGrouping() {
        let sine = Node(value: MathOperation.sine)
        sine.rightChild = Node(value: .x)
        let average = Node(value: MathOperation.average)
        average.leftChild = Node(value: .y)
        average.rightChild = sine
        let product = Node(value: MathOperation.multiply)
        product.leftChild = Node(value: .x)
        product.rightChild = average

        XCTAssertEqual(
            MathBinaryTree.describe(product, depth: 2),
            "(x × ((y + abs(sin(π × x))) / 2))"
        )
    }

    func testTrigonometricFormulaIncludesAbsoluteValueAndDepthScale() {
        let sine = Node(value: MathOperation.sine)
        sine.rightChild = Node(value: .x)
        let cosine = Node(value: MathOperation.cosine)
        cosine.rightChild = Node(value: .y)
        let average = Node(value: MathOperation.average)
        average.leftChild = sine
        average.rightChild = cosine

        XCTAssertEqual(
            MathBinaryTree.describe(average, depth: 1),
            "((abs(sin((π / 2) × x)) + abs(cos((π / 2) × y))) / 2)"
        )
        XCTAssertEqual(
            MathBinaryTree.describe(average, depth: 6),
            "((abs(sin(π × x)) + abs(cos(π × y))) / 2)"
        )
    }
}

@MainActor
final class WallpaperFormulaSnapshotTests: XCTestCase {
    func testFormulasStayWithDisplayedWallpaperUntilAnotherRenderSucceeds() throws {
        let canvas = CanvasV(frame: CGRect(x: 0, y: 0, width: 24, height: 8))
        XCTAssertNil(canvas.currentFormulas)
        canvas.changeDepth(with: 1)
        generate(canvas)

        let original = try XCTUnwrap(canvas.currentFormulas)
        XCTAssertEqual(original.depth, 1)
        for channel in [original.red, original.green, original.blue] {
            XCTAssertFalse(channel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }

        // The slider chooses the next generation, not a replacement for the image on screen.
        canvas.changeDepth(with: 2)
        XCTAssertEqual(canvas.currentFormulas, original)

        let exported = expectation(description: "Export retains the displayed equations")
        canvas.exportWallpaper { image in
            XCTAssertNotNil(image)
            exported.fulfill()
        }
        wait(for: [exported], timeout: 30)
        XCTAssertEqual(canvas.currentFormulas, original)

        // A failed generation must not discard the last successfully rendered formulas.
        canvas.bounds.size = .zero
        let rejected = expectation(description: "Empty canvas cannot generate")
        canvas.generateWallpaper { success in
            XCTAssertFalse(success)
            rejected.fulfill()
        }
        wait(for: [rejected], timeout: 2)
        XCTAssertEqual(canvas.currentFormulas, original)

        canvas.bounds.size = CGSize(width: 24, height: 8)
        generate(canvas)
        let replacement = try XCTUnwrap(canvas.currentFormulas)
        XCTAssertEqual(replacement.depth, 2)
        // Different stored depths make this deterministic even if random expressions repeat.
        XCTAssertNotEqual(replacement, original)
    }

    private func generate(_ canvas: CanvasV) {
        let finished = expectation(description: "Wallpaper generation completed")
        canvas.generateWallpaper { success in
            XCTAssertTrue(success)
            finished.fulfill()
        }
        wait(for: [finished], timeout: 10)
    }
}


// The introduction must always release the studio, including after interruption.
@MainActor
final class WallpaperLaunchAnimationTests: XCTestCase {
    private func fixture(accessibilityHidden: Bool = false) -> (UIView, UIView, WallpaperLaunchAnimationView) {
        let host = UIView(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        let content = UIView(frame: host.bounds)
        content.accessibilityElementsHidden = accessibilityHidden
        let opening = WallpaperLaunchAnimationView(frame: host.bounds)
        host.addSubview(content)
        host.addSubview(opening)
        return (host, content, opening)
    }

    func testOpeningFinishesAndRestoresStudioAccessibility() {
        let (host, content, opening) = fixture()
        let finished = expectation(description: "Opening releases the studio")
        opening.start(over: content, reduceMotion: false) { finished.fulfill() }
        XCTAssertTrue(content.accessibilityElementsHidden)
        XCTAssertNotNil(opening.superview)
        wait(for: [finished], timeout: 5)
        XCTAssertNil(opening.superview)
        XCTAssertFalse(content.accessibilityElementsHidden)
        XCTAssertEqual(host.subviews.count, 1)
    }

    func testReduceMotionFinishesWithoutLeavingAnOverlay() {
        let (host, content, opening) = fixture(accessibilityHidden: true)
        let finished = expectation(description: "Reduced-motion fade completes")
        opening.start(over: content, reduceMotion: true) { finished.fulfill() }
        wait(for: [finished], timeout: 2)
        XCTAssertNil(opening.superview)
        // Restore the previous value, even if this content was already hidden.
        XCTAssertTrue(content.accessibilityElementsHidden)
        XCTAssertEqual(host.subviews.count, 1)
    }

    func testInterruptionCompletesOnceAndCancelsDelayedDismissal() {
        let (host, content, opening) = fixture()
        var completions = 0
        opening.start(over: content, reduceMotion: false) { completions += 1 }
        opening.finishImmediately()
        opening.finishImmediately()
        XCTAssertEqual(completions, 1)
        XCTAssertNil(opening.superview)
        XCTAssertFalse(content.accessibilityElementsHidden)
        XCTAssertEqual(host.subviews.count, 1)
        // Wait beyond the scheduled automatic dismissal to expose stale work.
        let drained = expectation(description: "Old dismissal deadline passes")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) { drained.fulfill() }
        wait(for: [drained], timeout: 3)
        XCTAssertEqual(completions, 1)
    }

    func testSkipDismissesAndRestoresInteraction() throws {
        let (host, content, opening) = fixture()
        let finished = expectation(description: "Skip dismisses opening")
        opening.start(over: content, reduceMotion: false) { finished.fulfill() }
        let skip = try XCTUnwrap(opening.subviews.compactMap { $0 as? UIButton }
            .first { $0.accessibilityIdentifier == "skipLaunchAnimationButton" })
        skip.sendActions(for: .touchUpInside)
        wait(for: [finished], timeout: 2)
        XCTAssertNil(opening.superview)
        XCTAssertFalse(content.accessibilityElementsHidden)
        XCTAssertTrue(host.hitTest(CGPoint(x: 10, y: 10), with: nil) === content)
    }
}
