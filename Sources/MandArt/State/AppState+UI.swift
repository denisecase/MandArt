import SwiftUI

extension AppState {
  /// **Updates the rendered image.**
  func updateRenderedImage(_ newImage: NSImage) {
    renderedImage = newImage
  }

  /// **Marks that a full recalculation is required.**
  func updateRequiresFullCalc(_ newValue: Bool) {
    requiresFullCalc = newValue
  }

  /// **Shows or hides the color gradient preview.**
  func updateShowGradient(_ newValue: Bool) {
    showGradient = newValue
  }

  // MARK: Panel UI..............

  /// Updates an existing `PictureDefinition`
  func updatePicdef(_ newPicdef: PictureDefinition) {
    picdef.hues = newPicdef.hues
    picdef.leftNumber = newPicdef.leftNumber
    picdef.mandColor = newPicdef.mandColor
    picdef.scale = newPicdef.scale
    picdef.theta = newPicdef.theta
    picdef.iterationsMax = newPicdef.iterationsMax
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
