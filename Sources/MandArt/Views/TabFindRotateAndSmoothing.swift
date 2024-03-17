import SwiftUI
import UniformTypeIdentifiers

@available(macOS 12.0, *)
struct TabFindRotateAndSmoothing: View {
  @ObservedObject var doc: MandArtDocument
  @Binding var requiresFullCalc: Bool

  var body: some View {

    Section(
      header:
        Text("Set Rotation and Smoothing")
        .font(.headline)
        .fontWeight(.medium)
        .padding(.vertical)

    ) {
      HStack {
        Text("Rotation")
          .help("Enter degrees to rotate counter-clockwise.")

        DelayedTextFieldDouble(
          placeholder: "0",
          value: $doc.picdef.theta,
          formatter: MAFormatters.fmtRotationTheta
        )
        .textFieldStyle(.roundedBorder)
        .multilineTextAlignment(.trailing)
        .frame(maxWidth: 60)
        .help("Enter the angle to rotate the image counter-clockwise, in degrees.")
        .onChange(of: doc.picdef.theta) { _ in
          requiresFullCalc = true
        }
      } // end hstack theta



      HStack {
        Text("Color smoothing limit:")

        DelayedTextFieldDouble(
          placeholder: "400",
          value: $doc.picdef.rSqLimit,
          formatter: MAFormatters.fmtSmoothingRSqLimit
        )
        .textFieldStyle(.roundedBorder)
        .multilineTextAlignment(.trailing)
        .frame(maxWidth: 60)
        .help(
          "Enter the minimum value for the square of the distance from origin before the number of tries is ended. A larger value will smooth the color gradient, but slow down the calculation. Must be greater than 4. Rarely needs changing."
        )
        .onChange(of: doc.picdef.rSqLimit) { _ in
          requiresFullCalc = true
        }
      } // end hstack smoothing
    }
  }
}
