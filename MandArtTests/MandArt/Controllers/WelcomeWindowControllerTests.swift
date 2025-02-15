import AppKit
@testable import MandArt
import SwiftUI
import XCTest

@available(macOS 12.0, *)
class WelcomeWindowControllerTests: XCTestCase {
  var appState: AppState!
  var windowController: WelcomeWindowController!

  // Set up before each test
  override func setUpWithError() throws {
    super.setUp()
    // Initialize AppState for the test
    appState = AppState() // Assuming AppState is a simple class you can initialize

    // Initialize the WelcomeWindowController with appState
    windowController = WelcomeWindowController(appState: appState)
  }

  // Tear down after each test
  override func tearDownWithError() throws {
    windowController = nil
    appState = nil
    super.tearDown()
  }

  // Test that the window controller initializes correctly
  func testInitialization() {
    // Ensure that the WelcomeWindowController is created
    XCTAssertNotNil(windowController, "The WelcomeWindowController should be properly initialized.")

    // Ensure appState is passed correctly
    XCTAssertNotNil(windowController.appState, "The appState should be properly passed into WelcomeWindowController.")
  }

  // Test window size (using constants from AppConstants)
  func testWindowSize() {
    // Ensure the window size matches the expected default size
    let window = windowController.window

    let expectedWidth = MandArtApp.AppConstants.defaultWidth()
    let expectedHeight = MandArtApp.AppConstants.defaultHeight()

    XCTAssertEqual(window?.frame.width, expectedWidth, "Window width should match expected width.")
    XCTAssertEqual(window?.frame.height, expectedHeight, "Window height should match expected height.")
  }
}
