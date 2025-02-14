import Foundation
import SwiftData

/**
 `PictureDefinition`
 
 A model for managing MandArt user inputs, supporting JSON file storage and retrieval.
 
 - Note: Since `@Model` does not support `Codable`, we implement `Encodable` and `Decodable` manually.
 */
@Model
final class PictureDefinition {
    var id: UUID
    var xCenter: Double
    var yCenter: Double
    var scale: Double
    var iterationsMax: Double
    var rSqLimit: Double
    var imageWidth: Int
    var imageHeight: Int
    var nBlocks: Int
    var spacingColorFar: Double
    var spacingColorNear: Double
    var yY: Double
    var theta: Double
    var nImage: Int
    var dFIterMin: Double
    var leftNumber: Int
    var hues: [Hue]
    var mandColor: Hue
    var mandPowerReal: Int
    
    static let defaultHues: [Hue] = [
        Hue(num: 1, r: 0.0, g: 255.0, b: 0.0),
        Hue(num: 2, r: 255.0, g: 255.0, b: 0.0),
        Hue(num: 3, r: 255.0, g: 0.0, b: 0.0),
        Hue(num: 4, r: 255.0, g: 0.0, b: 255.0),
        Hue(num: 5, r: 0.0, g: 0.0, b: 255.0),
        Hue(num: 6, r: 0.0, g: 255.0, b: 255.0),
    ]
    
    // MARK: - Initializers
    
    /// Default initializer with optional hues
    init(
        hues: [Hue] = PictureDefinition.defaultHues
    ) {
        self.id = UUID()
        self.xCenter = -0.75
        self.yCenter = 0.0
        self.scale = 430.0
        self.iterationsMax = 10000.0
        self.rSqLimit = 500.0
        self.imageWidth = 1100
        self.imageHeight = 1000
        self.nBlocks = 60
        self.spacingColorFar = 5.0
        self.spacingColorNear = 15.0
        self.yY = 0.0
        self.theta = 0.0
        self.nImage = 0
        self.dFIterMin = 0.0
        self.leftNumber = 1
        self.hues = hues
        self.mandColor = Hue(num: 0, r: 0.0, g: 0.0, b: 0.0)
        self.mandPowerReal = 2
    }
}

// MARK: - Codable Implementation

extension PictureDefinition: Codable {
    
    enum CodingKeys: String, CodingKey {
        case id, xCenter, yCenter, scale, iterationsMax, rSqLimit, imageWidth, imageHeight, nBlocks,
             spacingColorFar, spacingColorNear, yY, theta, nImage, dFIterMin, leftNumber, hues, mandColor, mandPowerReal
    }
    
    /// **Custom Encoder** (for JSON Saving)
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(xCenter, forKey: .xCenter)
        try container.encode(yCenter, forKey: .yCenter)
        try container.encode(scale, forKey: .scale)
        try container.encode(iterationsMax, forKey: .iterationsMax)
        try container.encode(rSqLimit, forKey: .rSqLimit)
        try container.encode(imageWidth, forKey: .imageWidth)
        try container.encode(imageHeight, forKey: .imageHeight)
        try container.encode(nBlocks, forKey: .nBlocks)
        try container.encode(spacingColorFar, forKey: .spacingColorFar)
        try container.encode(spacingColorNear, forKey: .spacingColorNear)
        try container.encode(yY, forKey: .yY)
        try container.encode(theta, forKey: .theta)
        try container.encode(nImage, forKey: .nImage)
        try container.encode(dFIterMin, forKey: .dFIterMin)
        try container.encode(leftNumber, forKey: .leftNumber)
        try container.encode(hues, forKey: .hues)
        try container.encode(mandColor, forKey: .mandColor)
        try container.encode(mandPowerReal, forKey: .mandPowerReal)
    }
    
    /// **Custom Decoder** (for JSON Loading)
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let id = try container.decode(UUID.self, forKey: .id)
        let xCenter = try container.decode(Double.self, forKey: .xCenter)
        let yCenter = try container.decode(Double.self, forKey: .yCenter)
        let scale = try container.decode(Double.self, forKey: .scale)
        let iterationsMax = try container.decode(Double.self, forKey: .iterationsMax)
        let rSqLimit = try container.decode(Double.self, forKey: .rSqLimit)
        let imageWidth = try container.decode(Int.self, forKey: .imageWidth)
        let imageHeight = try container.decode(Int.self, forKey: .imageHeight)
        let nBlocks = try container.decode(Int.self, forKey: .nBlocks)
        let spacingColorFar = try container.decode(Double.self, forKey: .spacingColorFar)
        let spacingColorNear = try container.decode(Double.self, forKey: .spacingColorNear)
        let yY = try container.decode(Double.self, forKey: .yY)
        let theta = try container.decode(Double.self, forKey: .theta)
        let nImage = try container.decode(Int.self, forKey: .nImage)
        let dFIterMin = try container.decode(Double.self, forKey: .dFIterMin)
        let leftNumber = try container.decode(Int.self, forKey: .leftNumber)
        let hues = try container.decode([Hue].self, forKey: .hues)
        let mandColor = try container.decodeIfPresent(Hue.self, forKey: .mandColor) ?? Hue(num: 0, r: 0.0, g: 0.0, b: 0.0)
        let mandPowerReal = try container.decodeIfPresent(Int.self, forKey: .mandPowerReal) ?? 2

        self.init(hues: hues)
        
        self.id = id
        self.xCenter = xCenter
        self.yCenter = yCenter
        self.scale = scale
        self.iterationsMax = iterationsMax
        self.rSqLimit = rSqLimit
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.nBlocks = nBlocks
        self.spacingColorFar = spacingColorFar
        self.spacingColorNear = spacingColorNear
        self.yY = yY
        self.theta = theta
        self.nImage = nImage
        self.dFIterMin = dFIterMin
        self.leftNumber = leftNumber
        self.mandColor = mandColor
        self.mandPowerReal = mandPowerReal
    }
    
    // Get a color [Double] based on a number starting at one
    func getColorGivenNumberStartingAtOne(_ number: Int) -> [Double]? {
        let index = number - 1
        guard index >= 0 && index < hues.count else {
            return nil // Handle out-of-bounds index
        }
        return [hues[index].r, hues[index].g, hues[index].b]
    }
}
