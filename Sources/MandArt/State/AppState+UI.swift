import SwiftUI

extension AppState {
    
    /// **Updates the rendered image.**
    func updateRenderedImage(_ newImage: NSImage) {
        self.renderedImage = newImage
    }
    
    /// **Marks that a full recalculation is required.**
    func updateRequiresFullCalc(_ newValue: Bool) {
        self.requiresFullCalc = newValue
    }
    
    /// **Shows or hides the color gradient preview.**
    func updateShowGradient(_ newValue: Bool) {
        self.showGradient = newValue
    }
    
    // MARK: Panel UI..............
    
    /// Updates an existing `PictureDefinition`
     func updatePicdef(_ newPicdef: PictureDefinition) {
        self.picdef.hues = newPicdef.hues
        self.picdef.leftNumber = newPicdef.leftNumber
        self.picdef.mandColor = newPicdef.mandColor
        self.picdef.scale = newPicdef.scale
        self.picdef.theta = newPicdef.theta
        self.picdef.iterationsMax = newPicdef.iterationsMax
        saveToSwiftData()
    }
    
    /// Adds a new `PictureDefinition` instance if needed
     func addNewPictureDefinition() {
         guard let context = modelContainer?.mainContext else { return }
         let newPicdef = PictureDefinition()
         context.insert(newPicdef)
         saveToSwiftData()
    }
}
