import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct TabSave: View {
  @EnvironmentObject var appState: AppState
  @ObservedObject var popupManager = PopupManager()

  var body: some View {
    ScrollView {
      VStack {
        Section(
          header:
          Text("Save Your Art")
            .font(.headline)
            .fontWeight(.medium)
            .padding(.vertical)
        ) {
          Button("Save Picture Inputs (as data file)") {
            appState.picdef.saveMandArtImageInputs(appState: appState)
          }
          .help("Save MandArt picture inputs as .mandart.")

          Button("Save Picture As…") {
            appState.picdef.saveMandArtImageInputsAs(appState: appState)
          }
          .help("Save MandArt picture inputs to a new .mandart file.")

          Button("Export as PNG") {
            if let image = generateNSImage() {
              appState.picdef.saveMandArtImageAsPNG(image: image)
            } else {
              print("Error: Could not generate image")
            }
          }
          .help("Save MandArt picture as .png.")
        } // end section
      } // VStack
    } // ScrollView
    .onAppear {
      appState.updateRequiresFullCalc(false)
      appState.updateShowGradient(false)
    }
    .onDisappear {
      if appState.requiresFullCalc {
        appState.updateRequiresFullCalc(false)
      }
    }
  }

  /// **Generates an NSImage from the current MandArt view**
  private func generateNSImage() -> NSImage? {
    let picdef = appState.picdef
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
