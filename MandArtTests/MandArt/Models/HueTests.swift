import XCTest
import SwiftUI
@testable import MandArt

@available(macOS 12.0, *)
class HueTests: XCTestCase {

    var hue: Hue!
    
    // Set up before each test
    override func setUpWithError() throws {
        super.setUp()
        // Initialize Hue with default values
        hue = Hue()
    }

    // Tear down after each test
    override func tearDownWithError() throws {
        hue = nil
        super.tearDown()
    }

    // Test default initialization (should create a white color with num=0)
    func testDefaultInitialization() {
        XCTAssertNotNil(hue, "Hue should be properly initialized.")
        XCTAssertEqual(hue.num, 0, "The default num should be 0.")
        XCTAssertEqual(hue.r, 255, "The default red component should be 255.")
        XCTAssertEqual(hue.g, 255, "The default green component should be 255.")
        XCTAssertEqual(hue.b, 255, "The default blue component should be 255.")
        
        // Check that the default color is white
        XCTAssertEqual(hue.color, Color(.sRGB, red: 1, green: 1, blue: 1), "The default color should be white.")
    }

    // Test custom initialization with specific RGB values
    func testCustomInitialization() {
        let customHue = Hue(num: 1, r: 100, g: 150, b: 200)
        
        XCTAssertNotNil(customHue, "Custom Hue should be properly initialized.")
        XCTAssertEqual(customHue.num, 1, "The custom num should be 1.")
        XCTAssertEqual(customHue.r, 100, "The red component should be 100.")
        XCTAssertEqual(customHue.g, 150, "The green component should be 150.")
        XCTAssertEqual(customHue.b, 200, "The blue component should be 200.")
        
        // Check that the color is correctly set for custom RGB values
        XCTAssertEqual(customHue.color, Color(.sRGB, red: 100/255, green: 150/255, blue: 200/255), "The custom color should match the RGB values provided.")
    }

    // Test that two Hue objects with the same values are equal
    func testHueEquality() {
        let hue1 = Hue(num: 1, r: 100, g: 150, b: 200)
        let hue2 = Hue(num: 1, r: 100, g: 150, b: 200)
        
        XCTAssertEqual(hue1, hue2, "Two Hue objects with the same values should be equal.")
    }

    // Test that two Hue objects with different values are not equal
    func testHueInequality() {
        let hue1 = Hue(num: 1, r: 100, g: 150, b: 200)
        let hue2 = Hue(num: 2, r: 50, g: 100, b: 150)
        
        XCTAssertNotEqual(hue1, hue2, "Two Hue objects with different values should not be equal.")
    }
}
