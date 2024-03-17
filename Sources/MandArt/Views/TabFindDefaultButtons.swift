import SwiftUI
import UniformTypeIdentifiers

@available(macOS 12.0, *)
struct TabFindDefaultButtons: View {
  @ObservedObject var doc: MandArtDocument
  @Binding var requiresFullCalc: Bool
  @State private var didChange: Bool = false



  /// Initializes the view with a document and a binding to determine if a full calculation is required.
  ///
  /// - Parameters:
  ///   - doc: The document containing the image and scale data.
  ///   - requiresFullCalc: A binding to a Boolean indicating whether a full recalculation is required.
  init(doc: MandArtDocument, requiresFullCalc: Binding<Bool>) {
    _doc = ObservedObject(initialValue: doc)
    _requiresFullCalc = requiresFullCalc
  }

  func showDefaultMandArt(mandPowerReal: Double) {
    if (mandPowerReal == 2.0){
      doc.picdef.xCenter = -0.75
      doc.picdef.iterationsMax = 10000.0
    }
    else {
      doc.picdef.xCenter = 0.0
      doc.picdef.iterationsMax = 1000.0
    }
    doc.picdef.mandPowerReal = mandPowerReal
    doc.picdef.mandPowerImaginary = 0.0
    didChange = !didChange // Force redraw if needed
    requiresFullCalc = true
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
        Button("MandArt5 (be patient)") { showDefaultMandArt(mandPowerReal: 5) }
          .help("Like the Mandelbrot Set, but uses an exponent of 5.")
      }
      .padding(.bottom)

    }
    Divider()
  }
}
