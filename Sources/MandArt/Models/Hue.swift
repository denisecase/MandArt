import Foundation
import SwiftData
import SwiftUI // for Color

/**
 Represents a sorted color used in the MandArt project.
 
 Each `Hue` instance manages a single color with its RGB components and a corresponding SwiftUI `Color` object.
 It's used for sorting, encoding/decoding, and UI updates within the MandArt project.
 
 - `Codable`: Allows for JSON encoding/decoding.
 - `Identifiable`: Facilitates tracking and management in collections.
 
 Available from macOS 12.0 and later.
 */
@Model
final class Hue {
    var id: UUID
    var num: Int
    var r: Double
    var g: Double
    var b: Double
    
    /// Computed property to get the SwiftUI `Color`
    var color: Color {
        Color(red: r / 255, green: g / 255, blue: b / 255)
    }
    
    /** Initializes an instance of the `Hue` structure with given values for `num`, `r`, `g`, and `b`.
     - Parameters:
     - num: The integer value representing the hue number.
     - r: The red component of the color (0.0 to 255.0).
     - g: The green component of the color (0.0 to 255.0).
     - b: The blue component of the color (0.0 to 255.0).
     */
    init(id: UUID = UUID(), num: Int = 1, r: Double = 0.0, g: Double = 255.0, b: Double = 0.0) {
        self.id = id
        self.num = num
        self.r = r
        self.g = g
        self.b = b
    }
}

// MARK: - Codable Implementation

extension Hue: Codable {
    
    enum CodingKeys: String, CodingKey {
        case id, num, r, g, b
    }
    
    /// **Custom Encoder** (for JSON Saving)
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(num, forKey: .num)
        try container.encode(r, forKey: .r)
        try container.encode(g, forKey: .g)
        try container.encode(b, forKey: .b)
    }
    
    /// **Custom Decoder** (for JSON Loading)
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
