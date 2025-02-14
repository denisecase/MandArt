import SwiftUI
import SwiftData

@MainActor
class ImageViewModel: ObservableObject {
    let appState: AppState
    private var previousPicdef: PictureDefinition?
    private var _cachedArtImage: CGImage?
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    
    /// A computed property for managing a cached MandArt image.
    /// It checks if a new image calculation is required based on the current document settings.
    var cachedArtImage: CGImage? {
        get {
            if _cachedArtImage == nil || keyVariablesChanged {
                var colors: [[Double]] = appState.picdef.hues.map { [$0.r, $0.g, $0.b] }
                let art = ArtImage(picdef: appState.picdef)
                _cachedArtImage = appState.requiresFullCalc ?
                art.getGrandArtFullPictureImage(colors: &colors) :
                art.getNewlyColoredImage(colors: &colors)
            }
            return _cachedArtImage
        }
        set {
            _cachedArtImage = newValue
        }
    }

    
    /// Calculates the right number for gradient display based on whether the left gradient number is valid.
    /// - Parameter leftGradientIsValid: A Boolean indicating whether the left gradient number is valid.
    /// - Returns: The calculated right number for the gradient.
    func getCalculatedRightNumber(leftGradientIsValid: Bool) -> Int {
        if leftGradientIsValid, appState.picdef.leftNumber < appState.picdef.hues.count {
            return appState.picdef.leftNumber + 1
        }
        return 1
    }
    
    /// Determines whether the left gradient number is valid.
    /// - Returns: A Boolean indicating whether the left gradient number is valid.
    func getLeftGradientIsValid() -> Bool {
        let leftNum = appState.picdef.leftNumber
        let lastPossible = appState.picdef.hues.count
        return leftNum >= 1 && leftNum <= lastPossible
    }
    
    /// A private computed property to check if key variables of the picture definition have changed.
    private var keyVariablesChanged: Bool {
        guard let previousPicdef = previousPicdef else {
            self.previousPicdef = appState.picdef
            return true
        }
        
        let hasChanged =
        previousPicdef.imageWidth != appState.picdef.imageWidth ||
        previousPicdef.imageHeight != appState.picdef.imageHeight ||
        previousPicdef.xCenter != appState.picdef.xCenter ||
        previousPicdef.yCenter != appState.picdef.yCenter ||
        previousPicdef.theta != appState.picdef.theta ||
        previousPicdef.scale != appState.picdef.scale ||
        previousPicdef.iterationsMax != appState.picdef.iterationsMax ||
        previousPicdef.rSqLimit != appState.picdef.rSqLimit
        
        if hasChanged {
            self.previousPicdef = appState.picdef
        }
        
        return hasChanged
    }
    
    /// Retrieves the current image to be displayed.
    /// This method decides whether to return a cached image, calculate a new image,
    /// or show a gradient based on the current state.
    /// - Returns: An optional `CGImage` representing the current image.
    func getImage() -> CGImage? {
        if appState.showGradient && getLeftGradientIsValid() {
            return getGradientImage()
        }
        return cachedArtImage
    }
    
    /// Generates a gradient image based on the left and right color values.
    /// - Returns: An optional `CGImage` representing the gradient.
    func getGradientImage() -> CGImage? {
        let leftNumber = appState.picdef.leftNumber
        let rightNumber = getCalculatedRightNumber(leftGradientIsValid: getLeftGradientIsValid())
        
        guard let leftColorRGBArray = appState.picdef.getColorGivenNumberStartingAtOne(leftNumber) else {
            return nil
        }
        guard let rightColorRGBArray = appState.picdef.getColorGivenNumberStartingAtOne(rightNumber) else {
            return nil
        }
        
        let gradientParameters = GradientImage.GradientImageInputs(
            imageWidth: 500, // self.appState.picdef.imageWidth,
            imageHeight: 500, // self.appState.picdef.imageHeight,
            leftColorRGBArray: leftColorRGBArray,
            rightColorRGBArray: rightColorRGBArray,
            gradientThreshold: 0.0 // self.appState.picdef.yY
        )
        return GradientImage.createCGImage(using: gradientParameters)
    }
}
