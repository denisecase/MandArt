import AppKit
import SwiftData

extension AppState {
  /// **Resets MandArt to default and deletes previous instances.**
  @MainActor
  func resetMandArt() {
    print("Resetting MandArt to default.")

    guard let container = modelContainer else {
      print("ERROR: SwiftData container is missing!")
      return
    }

    let context = container.mainContext

    // Delete all old instances to prevent conflicts
    let existingPicdefs = try? context.fetch(FetchDescriptor<PictureDefinition>())
    existingPicdefs?.forEach { context.delete($0) }

    // Create and save a new default MandArt
    let newPicdef = PictureDefinition()
    context.insert(newPicdef)

    do {
      try context.save()
      picdef = newPicdef
      activeFileName = "DefaultMandArt.mandart"
      currentFileURL = nil // Ensures "Save" prompts for a location
      print("Saved new default MandArt: \(newPicdef.id)")
    } catch {
      print("ERROR saving new default MandArt: \(error)")
    }
  }

  /// **Prompts the user before replacing MandArt.**
  func promptReplaceMandArt(action: @escaping () -> Void) {
    pendingReplacement = action
    showReplaceAlert = true
  }

  /// **Confirms and executes the MandArt replacement.**
  func confirmReplaceMandArt() {
    pendingReplacement?()
    pendingReplacement = nil
  }

  /// **Replaces the current MandArt with a fresh default instance.**
  func replaceMandArt() {
    print("CAUTION: Replacing current MandArt.")
    promptReplaceMandArt { [weak self] in
      guard let self = self, let container = modelContainer else { return }

      let context = container.mainContext
      let newPicdef = PictureDefinition()
      context.insert(newPicdef)

      do {
        try context.save()
        self.picdef = newPicdef
      } catch {
        print("ERROR replacing MandArt: \(error)")
      }
    }
  }

  /// **Generates an NSImage from the current MandArt view**
  func generateNSImage() -> NSImage? {
    let picdef = self.picdef
    let size = NSSize(width: picdef.imageWidth, height: picdef.imageHeight)
    let image = NSImage(size: size)

    image.lockFocus() // Start drawing
    NSColor.white.setFill()
    NSRect(origin: .zero, size: size).fill() // Fill background

    // Example: Draw a rectangle with the primary hue color
    if let firstHue = picdef.hues.first {
      let color = NSColor(red: firstHue.r / 255, green: firstHue.g / 255, blue: firstHue.b / 255, alpha: 1)
      color.setFill()
      NSRect(x: 10, y: 10, width: size.width - 20, height: size.height - 20).fill()
    }

    image.unlockFocus() // Stop drawing
    return image
  }
}
