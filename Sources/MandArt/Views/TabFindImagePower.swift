import SwiftUI
import UniformTypeIdentifiers

@available(macOS 12.0, *)
struct TabFindImagePower: View {
  @ObservedObject var doc: MandArtDocument
  @Binding var requiresFullCalc: Bool

  var body: some View {
    Section(
      header:
      Text("Set Max Tries and Power")
        .font(.headline)
        .fontWeight(.medium)
        .padding(.vertical)

    ) {
      HStack {
        Text("Maximum number of tries")

        DelayedTextFieldDouble(
          placeholder: "10,000",
          value: $doc.picdef.iterationsMax,
          formatter: MAFormatters.fmtSharpeningItMax
        )
        .textFieldStyle(.roundedBorder)
        .multilineTextAlignment(.trailing)
        .help(
          "Enter the maximum number of tries for a given point in the image. A larger value will increase the resolution, but slow down the calculation and make the coloring more difficult."
        )
        .frame(maxWidth: 70)
        .onChange(of: doc.picdef.iterationsMax) { _ in
          requiresFullCalc = true
        }
      } // end hstack sharpening
      .padding(.horizontal)

      HStack {
        VStack {
          Text("Real Power")
          Text("Between 2 and 12")
          DelayedTextFieldDouble(
            placeholder: "2.0",
            value: $doc.picdef.mandPowerReal,
            formatter: MAFormatters.fmtPowerReal
          )
          .textFieldStyle(.roundedBorder)
          .multilineTextAlignment(.trailing)
          .frame(maxWidth: 40)
          .help(
            "The default is 2.0 for regular MandArt. Choose a number from 2 to 12. Recommended: If > 2, consider seting Max Iterations to 1000 for quicker response and change xCenter to 0.0."
          )
          .onChange(of: doc.picdef.mandPowerReal) { _ in
            requiresFullCalc = true
          }
        } // end vstack
        .padding(.trailing)

        VStack {
          Text("Imaginary Power")
          Text("Between 0 and 12")
          DelayedTextFieldDouble(
            placeholder: "0.0",
            value: $doc.picdef.mandPowerImaginary,
            formatter: MAFormatters.fmtPowerImaginary
          )
          .frame(maxWidth: 40)
          .help("The default is 0.0 for regular Mandart. Choose a number from 0 to 12.")
          .onChange(of: doc.picdef.mandPowerImaginary) { _ in
            requiresFullCalc = true
          }
        } // end vstack
      }
    }
    Divider()
  }
}
