import SwiftUI
import UniformTypeIdentifiers

@available(macOS 12.0, *)
struct TabFindRotateAndSmoothing: View {
    @Binding var picdef: PictureDefinition
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
                    value: $picdef.theta,
                    formatter: MAFormatters.fmtRotationTheta
                )
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 60)
                .help("Enter the angle to rotate the image counter-clockwise, in degrees.")
                .onChange(of: picdef.theta) { _ ,_ in // two params in Mac 14.0+
                    requiresFullCalc = true
                }
            } // end hstack theta
            
            HStack {
                Text("Color smoothing limit:")
                
                DelayedTextFieldDouble(
                    placeholder: "400",
                    value: $picdef.rSqLimit,
                    formatter: MAFormatters.fmtSmoothingRSqLimit
                )
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 60)
                .help(
                    "Enter the minimum value for the square of the distance from origin before the number of tries is ended. A larger value will smooth the color gradient, but slow down the calculation. Must be greater than 4. Rarely needs changing."
                )
                .onChange(of: picdef.rSqLimit) { _ ,_ in // two params in Mac 14.0+
                    requiresFullCalc = true
                }
            } // end hstack smoothing
        }
    }
}
