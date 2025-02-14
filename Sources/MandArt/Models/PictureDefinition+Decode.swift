///**
// Exend `PictureDefinition` class to meet the `Decodable` protocol.
//
// Allows the file to be decoded from JSON .mandart format.
//
// */
//
//import Foundation
//import SwiftUI
//
//@available(macOS 12.0, *)
//extension PictureDefinition {
//  enum CodingKeys: String, CodingKey {
//    case id, xCenter, yCenter, scale, iterationsMax, rSqLimit, imageWidth, imageHeight, nBlocks, spacingColorFar,
//         spacingColorNear, yY, theta, nImage, dFIterMin, leftNumber, hues,
//         mandColor, mandPowerReal
//  }
//
//  init(from decoder: Decoder) throws {
//    let container = try decoder.container(keyedBy: CodingKeys.self)
//    id = try container.decode(UUID.self, forKey: .id)
//    xCenter = try container.decode(Double.self, forKey: .xCenter)
//    yCenter = try container.decode(Double.self, forKey: .yCenter)
//    scale = try container.decode(Double.self, forKey: .scale)
//    iterationsMax = try container.decode(Double.self, forKey: .iterationsMax)
//    rSqLimit = try container.decode(Double.self, forKey: .rSqLimit)
//    imageWidth = try container.decode(Int.self, forKey: .imageWidth)
//    imageHeight = try container.decode(Int.self, forKey: .imageHeight)
//    nBlocks = try container.decode(Int.self, forKey: .nBlocks)
//    spacingColorFar = try container.decode(Double.self, forKey: .spacingColorFar)
//    spacingColorNear = try container.decode(Double.self, forKey: .spacingColorNear)
//    yY = try container.decode(Double.self, forKey: .yY)
//    theta = try container.decode(Double.self, forKey: .theta)
//    nImage = try container.decode(Int.self, forKey: .nImage)
//    dFIterMin = try container.decode(Double.self, forKey: .dFIterMin)
//    leftNumber = try container.decode(Int.self, forKey: .leftNumber)
//    hues = try container.decode([Hue].self, forKey: .hues)
//
//    // Decoding mandColor with a default value if not present
//    let defaultMandColor = Hue(num: 0, r: 0.0, g: 0.0, b: 0.0) // Default black color
//    mandColor = try container.decodeIfPresent(Hue.self, forKey: .mandColor) ?? defaultMandColor
//
//    // Decoding mandPowerReal with a default value if not present
//    let defaultMandPowerReal = 2
//    mandPowerReal = try container.decodeIfPresent(Int.self, forKey: .mandPowerReal) ?? defaultMandPowerReal
//
//  }
//}
