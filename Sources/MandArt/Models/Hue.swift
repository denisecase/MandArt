import Foundation
import SwiftUI // for Color

/// Represents a sorted color used in the MandArt project.
/// SwiftData does not reliably support arrays of @Model objects yet.

/// Represents a sorted color used in the MandArt project.
final class Hue: Identifiable, Codable, Equatable {
  var id: UUID
  var num: Int // Order in the list
  var r: Double
  var g: Double
  var b: Double

  /// Computed property to get the SwiftUI `Color`
  var color: Color {
    Color(red: r / 255, green: g / 255, blue: b / 255)
  }

  /// Initializes a `Hue` instance
  init(id: UUID = UUID(), num: Int = 1, r: Double = 0.0, g: Double = 255.0, b: Double = 0.0) {
    self.id = id
    self.num = num
    self.r = r
    self.g = g
    self.b = b
  }

  /// **Updates hue values from a SwiftUI `Color`**
  func update(from color: Color) {
    if let components = color.cgColor?.components, components.count >= 3 {
      r = components[0] * 255.0
      g = components[1] * 255.0
      b = components[2] * 255.0
    }
  }

  /// **Returns a new `Hue` with updated color values.**
  func updated(with color: Color) -> Hue {
    guard let components = color.cgColor?.components, components.count >= 3 else { return self }
    return Hue(num: num, r: components[0] * 255, g: components[1] * 255, b: components[2] * 255)
  }

  /// Default hue for convenience (0,0,0 = black)
  static let defaultHue = Hue(num: 1, r: 0, g: 0, b: 0)

  /// Equatable conformance
  static func == (lhs: Hue, rhs: Hue) -> Bool {
    return lhs.id == rhs.id && lhs.num == rhs.num && lhs.r == rhs.r && lhs.g == rhs.g && lhs.b == rhs.b
  }
}

/// Extension to extract RGB components from `Color`
extension Color {
  /// Extracts RGB components safely
  var uiColorComponents: (red: Double, green: Double, blue: Double)? {
    #if canImport(UIKit)
      guard let cgColor = cgColor else { return nil }
      let components = cgColor.components ?? []
      let red = components.count > 0 ? Double(components[0]) : 0.0
      let green = components.count > 1 ? Double(components[1]) : 0.0
      let blue = components.count > 2 ? Double(components[2]) : 0.0
      return (red, green, blue)
    #else
      return nil
    #endif
  }
}
