import Foundation
import SwiftData
import SwiftUI // for Color

/**
 `PictureDefinition`
 
 A model for managing MandArt user inputs, supporting JSON file storage and retrieval.
 
 - Note: SwiftData does not support direct arrays of structs
 */
@Model
final class PictureDefinition: Codable, ObservableObject {
    
    // Reference to SwiftData Context
    @Transient var context: ModelContext?
    
    /// Hues stored as JSON (SwiftData cannot store arrays of structs yet)
     var huesData: Data = Data() {
        didSet { decodeHues() }
    }
    
    /// Store `mandColor` as JSON-encoded data
     var mandColorData: Data = Data() {
        didSet { decodeMandColor() }
    }

    
    
    /// UI-facing hues array (not stored directly in SwiftData)
    var hues: [Hue] {
        get {
            (try? JSONDecoder().decode([Hue].self, from: huesData)) ?? []
        }
        set {
            huesData = (try? JSONEncoder().encode(newValue)) ?? Data()
            objectWillChange.send()  // Force UI update
            saveToSwiftData()
            print("Saved hues: \(newValue)")
        }
    }
    
    /// Computed property for accessing `mandColor`
    var mandColor: Hue {
        get { (try? JSONDecoder().decode(Hue.self, from: mandColorData)) ?? Hue.defaultHue }
        set {
            mandColorData = (try? JSONEncoder().encode(newValue)) ?? Data()
            objectWillChange.send()
            saveToSwiftData()
        }
    }

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
    var mandPowerReal: Int

    
    /// Default hues used for initialization
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
        hues: [Hue] = PictureDefinition.defaultHues,
        mandColor: Hue = Hue.defaultHue,
        mandPowerReal: Int = 2
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
        self.huesData = (try? JSONEncoder().encode(hues)) ?? Data()
        self.mandColorData = (try? JSONEncoder().encode(mandColor)) ?? Data()
        self.mandPowerReal = mandPowerReal
        decodeHues()
    }
    
    // MARK: - Helper Functions Getters
    
    /// **Computes the Right Number for Gradients**
    @MainActor
    var calculatedRightNumber: Int {
        (leftNumber >= 1 && leftNumber < hues.count) ? leftNumber + 1 : 1
    }
    
 
        private func decodeHues() {
            let decoded = (try? JSONDecoder().decode([Hue].self, from: huesData)) ?? []
            print("Decoded hues: \(decoded)") // Debugging
            hues = decoded.isEmpty ? PictureDefinition.defaultHues : decoded
        }
   
    
    /// Decode `mandColor` when the data changes
    private func decodeMandColor() {
        let decoded = (try? JSONDecoder().decode(Hue.self, from: mandColorData)) ?? Hue.defaultHue
        print("Decoded mandColor: \(decoded)") // Debugging
        mandColor = decoded
    }
    
    /// **Returns the row number for a given hue index** (1-based index).
    @MainActor
    func rowNumber(for index: Int) -> Int {
        index + 1
    }
    
    /// **Checks if the hue index is valid.**
    func isHueIndexValid(_ index: Int) -> Bool {
        hues.indices.contains(index)
    }
    
    /// **Determines if a color is likely to print accurately.**
    func isPrintableColor(at index: Int) -> Bool {
        guard isHueIndexValid(index) else { return true }
        return MandMath.isColorNearPrintableList(
            color: hues[index].color.cgColor!,
            num: hues[index].num
        )
    }
    
    /// Get color values as [Double] given a hue number (1-based index)
    func getColorGivenNumberStartingAtOne(_ number: Int) -> [Double]? {
        let index = number - 1
        guard index >= 0, index < hues.count else {
            return nil // Out-of-bounds index
        }
        return [hues[index].r, hues[index].g, hues[index].b]
    }

    
    // MARK: - Helper Functions Updates
    
    // Encode hues back into JSON when modified
    private func encodeHues() {
        huesData = (try? JSONEncoder().encode(hues)) ?? Data()
        saveToSwiftData()
    }
    
    
    /// **Updates the Mandelbrot Set Color**
    @MainActor
    func updateMandColor(to newColor: Color) {
        mandColor.update(from: newColor)
    }
    
    /// **Ensures all hues are numbered correctly in order.**
    @MainActor
    func updateHueNumbers() {
        for (i, _) in hues.enumerated() {
            hues[i].num = i + 1
        }
        encodeHues()
    }
    
    // MARK: - SwiftData Integration
    
    /// Save changes to SwiftData
     func saveToSwiftData() {
        guard let context = context else { return }
        do {
            try context.save()
            print("Saved changes to SwiftData")
        } catch {
            print("Error saving SwiftData: \(error)")
        }
    }
        
    
    // MARK: - Create Default
    
    @MainActor
    static func create_default() -> PictureDefinition {
        return PictureDefinition()
    }
    
    // MARK: - Core Hue Management (Simple, No Undo)
    
    /// Save changes to SwiftData
    @MainActor
    func saveModelContext(_ context: ModelContext) {
        do {
            try context.save()
            print("Successfully saved changes to SwiftData")
        } catch {
            print("Error saving SwiftData: \(error)")
        }
    }

    /// Adds a hue (without undo tracking)
    @MainActor
    func addHue(_ hue: Hue) {
        var huesList = hues //mutable
        huesList.append(hue)
        hues = huesList
        updatePicdef()
    }
    
    /// Removes a hue at a given index (without undo tracking)
    @MainActor
    func removeHue(at index: Int) {
        guard hues.indices.contains(index) else { return }
        // Make a mutable copy, remove the hue, then replace the array
        var huesList = hues
        huesList.remove(at: index)
        hues = huesList // trigger didSet -> encodeHues()
        updatePicdef()
    }
    
    /// Updates a hue at a given index (without undo tracking)
    @MainActor
    func updateHue(at index: Int, with hue: Hue) {
        guard hues.indices.contains(index) else { return }
        var huesList  = hues // mutable
        huesList[index] = hue
        hues = huesList
        updatePicdef()
    }
    
    @MainActor
    func updatePicdef() {
        objectWillChange.send()  // 🔹 Explicitly notify SwiftUI of a change
        encodeHues()             // 🔹 Ensure huesData is updated
        saveToSwiftData()        // 🔹 Save the new hues state
        print("picdef updated: \(self)")
    }

    // MARK: - Codable Implementation

    enum CodingKeys: String, CodingKey {
        case id, xCenter, yCenter, scale, iterationsMax, rSqLimit, imageWidth, imageHeight, nBlocks,
             spacingColorFar, spacingColorNear, yY, theta, nImage, dFIterMin, leftNumber, huesData, mandColorData, mandPowerReal
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
        try container.encode(huesData, forKey: .huesData)
        try container.encode(mandColorData, forKey: .mandColorData)
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
        let huesData = try container.decode(Data.self, forKey: .huesData)
        let mandColorData = try container.decode(Data.self, forKey: .mandColorData)
        let mandPowerReal = try container.decode(Int.self, forKey: .mandPowerReal)
        
        let hues = (try? JSONDecoder().decode([Hue].self, from: huesData)) ?? []
        let mandColor = (try? JSONDecoder().decode(Hue.self, from: mandColorData)) ?? Hue.defaultHue
        
        self.init(hues: hues, mandColor: mandColor, mandPowerReal: mandPowerReal)
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

    }
    
}
