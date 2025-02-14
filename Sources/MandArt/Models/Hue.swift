import Foundation
import SwiftData
import SwiftUI // for Color

/// Represents a sorted color used in the MandArt project.
@Model
final class Hue: Identifiable, Codable, Equatable {
    var id: UUID  // IDs should be immutable
    var num: Int  // Order in the list
    var r: Double
    var g: Double
    var b: Double
    
    /// Computed property to get the SwiftUI `Color`
    @Transient
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
    
    /// Default hue for convenience
    static let defaultHue = Hue(num: 1, r: 255, g: 255, b: 255)
    
    /// Equatable conformance (needed for undo operations)
    static func == (lhs: Hue, rhs: Hue) -> Bool {
        return lhs.id == rhs.id && lhs.num == rhs.num && lhs.r == rhs.r && lhs.g == rhs.g && lhs.b == rhs.b
    }
    
    /// Codable conformance
    enum CodingKeys: String, CodingKey {
        case id, num, r, g, b
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(num, forKey: .num)
        try container.encode(r, forKey: .r)
        try container.encode(g, forKey: .g)
        try container.encode(b, forKey: .b)
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let num = try container.decode(Int.self, forKey: .num)
        let r = try container.decode(Double.self, forKey: .r)
        let g = try container.decode(Double.self, forKey: .g)
        let b = try container.decode(Double.self, forKey: .b)
        self.init(id: id, num: num, r: r, g: g, b: b)
    }
}
