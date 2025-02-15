import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct TabFindDefaultButtons: View {
  @EnvironmentObject var appState: AppState
  @State private var didChange: Bool = false

  func showDefaultMandArt(mandPowerReal: Int) {
    if mandPowerReal == 2 {
      appState.picdef.imageWidth = 1100
      appState.picdef.imageHeight = 1000
      appState.picdef.xCenter = -0.75
      appState.picdef.yCenter = 0.0
      appState.picdef.theta = 0.0
      appState.picdef.scale = 430.0
      appState.picdef.iterationsMax = 10000.0
      appState.picdef.rSqLimit = 500.0

    } else if mandPowerReal == 3 {
      appState.picdef.imageWidth = 1100
      appState.picdef.imageHeight = 1000
      appState.picdef.xCenter = 0.0
      appState.picdef.yCenter = 0.0
      appState.picdef.theta = 0.0
      appState.picdef.iterationsMax = 10000.0
      appState.picdef.scale = 360.0
      appState.picdef.rSqLimit = 64.0
    } else {
      appState.picdef.imageWidth = 1100
      appState.picdef.imageHeight = 1000
      appState.picdef.xCenter = 0.0
      appState.picdef.yCenter = 0
      appState.picdef.theta = 0.0
      appState.picdef.iterationsMax = 50.0
      appState.picdef.scale = 430.0
      appState.picdef.rSqLimit = 25.0
    }
    appState.picdef.mandPowerReal = mandPowerReal
    //  appState.picdef.mandPowerImaginary = 0.0
    didChange = !didChange // Force redraw if needed
    appState.updateRequiresFullCalc(true)
  }

  var body: some View {
    Section(
      header:
      Text("Get a Default MandArt")
        .font(.headline)
        .fontWeight(.medium)
        .padding(.vertical)
    ) {
      HStack {
        Button("MandArt (2)") { showDefaultMandArt(mandPowerReal: 2) }
          .help("Based on the Mandelbrot Set.")
        Button("MandArt3") { showDefaultMandArt(mandPowerReal: 3) }
          .help("Like the Mandelbrot Set, but uses an exponent of 3.")
        Button("MandArt4") { showDefaultMandArt(mandPowerReal: 4) }
          .help("Like the Mandelbrot Set, but uses an exponent of 4.")
      }
      HStack {
        Button("MandArt5") { showDefaultMandArt(mandPowerReal: 5) }
          .help("Like the Mandelbrot Set, but uses an exponent of 5.")
        Button("MandArt6") { showDefaultMandArt(mandPowerReal: 6) }
          .help("Like the Mandelbrot Set, but uses an exponent of 6.")
        Button("MandArt7") { showDefaultMandArt(mandPowerReal: 7) }
          .help("Like the Mandelbrot Set, but uses an exponent of 7.")
      }
      HStack {
        Button("MandArt8") { showDefaultMandArt(mandPowerReal: 8) }
          .help("Like the Mandelbrot Set, but uses an exponent of 8.")
        Button("MandArt9") { showDefaultMandArt(mandPowerReal: 9) }
          .help("Like the Mandelbrot Set, but uses an exponent of 9.")
        Button("MandArt10") { showDefaultMandArt(mandPowerReal: 10) }
          .help("Like the Mandelbrot Set, but uses an exponent of 10.")
      }
      HStack {
        Button("MandArt11") { showDefaultMandArt(mandPowerReal: 11) }
          .help("Like the Mandelbrot Set, but uses an exponent of 11.")
        Button("MandArt12") { showDefaultMandArt(mandPowerReal: 12) }
          .help("Like the Mandelbrot Set, but uses an exponent of 12.")
      }
      .padding(.bottom)
    }
    Divider()
  }
}
