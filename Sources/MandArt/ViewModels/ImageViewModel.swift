import SwiftUI
import SwiftData

/// A ViewModel for managing and displaying images in a SwiftUI view.
/// This class handles the logic for calculating images based on the provided document,
/// and manages whether a full calculation is required or if a gradient should be shown.
class ImageViewModel: ObservableObject {
    @Bindable var picdef: PictureDefinition
    @Binding var requiresFullCalc: Bool
    @Binding var showGradient: Bool
    
    private var previousPicdef: PictureDefinition?
    private var _cachedArtImage: CGImage?
    
    /// A computed property for managing a cached MandArt image.
    /// It checks if a new image calculation is required based on the current document settings.
    var cachedArtImage: CGImage? {
        get {
            if _cachedArtImage == nil || keyVariablesChanged {
                var colors: [[Double]] = picdef.hues.map { [$0.r, $0.g, $0.b] }
                let art = ArtImage(picdef: picdef)
                _cachedArtImage = requiresFullCalc ?
                art.getGrandArtFullPictureImage(colors: &colors) :
                art.getNewlyColoredImage(colors: &colors)
            }
            return _cachedArtImage
        }
        set {
            _cachedArtImage = newValue
        }
    }
    
    /// Initializes a new instance of `ImageViewModel`.
    /// - Parameters:
    /// - picdef: The `PictureDefinition` instance to use.
    ///   - requiresFullCalc: A binding to a Boolean value indicating whether a full image calculation is required.
    ///   - showGradient: A binding to a Boolean value indicating whether to show a gradient.
    init(picdef: PictureDefinition, requiresFullCalc: Binding<Bool>, showGradient: Binding<Bool>) {
        self.picdef = picdef
        _requiresFullCalc = requiresFullCalc
        _showGradient = showGradient
    }
    
    /// Calculates the right number for gradient display based on whether the left gradient number is valid.
    /// - Parameter leftGradientIsValid: A Boolean indicating whether the left gradient number is valid.
    /// - Returns: The calculated right number for the gradient.
    func getCalculatedRightNumber(leftGradientIsValid: Bool) -> Int {
        if leftGradientIsValid, picdef.leftNumber < picdef.hues.count {
            return picdef.leftNumber + 1
        }
        return 1
    }
    
    /// Determines whether the left gradient number is valid.
    /// - Returns: A Boolean indicating whether the left gradient number is valid.
    func getLeftGradientIsValid() -> Bool {
        let leftNum = picdef.leftNumber
        let lastPossible = picdef.hues.count
        return leftNum >= 1 && leftNum <= lastPossible
    }
    
    /// A private computed property to check if key variables of the picture definition have changed.
    private var keyVariablesChanged: Bool {
        guard let previousPicdef = previousPicdef else {
            self.previousPicdef = picdef
            return true
        }
        
        let hasChanged =
        previousPicdef.imageWidth != picdef.imageWidth ||
        previousPicdef.imageHeight != picdef.imageHeight ||
        previousPicdef.xCenter != picdef.xCenter ||
        previousPicdef.yCenter != picdef.yCenter ||
        previousPicdef.theta != picdef.theta ||
        previousPicdef.scale != picdef.scale ||
        previousPicdef.iterationsMax != picdef.iterationsMax ||
        previousPicdef.rSqLimit != picdef.rSqLimit
        
        if hasChanged {
            self.previousPicdef = picdef
        }
        
        return hasChanged
    }
    
    /// Retrieves the current image to be displayed.
    /// This method decides whether to return a cached image, calculate a new image,
    /// or show a gradient based on the current state.
    /// - Returns: An optional `CGImage` representing the current image.
    func getImage() -> CGImage? {
        if showGradient && getLeftGradientIsValid() {
            return getGradientImage()
        }
        return cachedArtImage
    }
    
    /// Generates a gradient image based on the left and right color values.
    /// - Returns: An optional `CGImage` representing the gradient.
    func getGradientImage() -> CGImage? {
        let leftNumber = picdef.leftNumber
        let rightNumber = getCalculatedRightNumber(leftGradientIsValid: getLeftGradientIsValid())
        
        guard let leftColorRGBArray = picdef.getColorGivenNumberStartingAtOne(leftNumber) else {
            return nil
        }
        guard let rightColorRGBArray = picdef.getColorGivenNumberStartingAtOne(rightNumber) else {
            return nil
        }
        
        let gradientParameters = GradientImage.GradientImageInputs(
            imageWidth: 500, // self.picdef.imageWidth,
            imageHeight: 500, // self.picdef.imageHeight,
            leftColorRGBArray: leftColorRGBArray,
            rightColorRGBArray: rightColorRGBArray,
            gradientThreshold: 0.0 // self.picdef.yY
        )
        return GradientImage.createCGImage(using: gradientParameters)
    }
}
