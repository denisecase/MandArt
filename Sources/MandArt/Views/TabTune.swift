import SwiftUI
import UniformTypeIdentifiers

@available(macOS 12.0, *)
struct TabTune: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    Text("Color spacing far from Mini-Mand (near to edge)")
                    SliderTextView(
                        range: 0 ... 20,
                        step: 1,
                        placeholder: "5",
                        formatter: MAFormatters.fmtSpacingNearEdge,
                        helpText: "Enter the value for the color spacing near the edges of the image, away from Mini-Mand.",
                        value: $appState.picdef.spacingColorFar
                    )
                }
                
                VStack(spacing: 10) {
                    Text("Color spacing near to Mini-Mand (far from edge)")
                    SliderTextView(
                        range: 5 ... 50,
                        step: 5,
                        placeholder: "15",
                        formatter: MAFormatters.fmtSpacingFarFromEdge,
                        helpText: "Enter the value for the color spacing away from the edges of the image, near the Mini-Mand.",
                        value: $appState.picdef.spacingColorNear
                    )
                }
                
                // dFIterMin
                VStack(spacing: 10) {
                    Text("Change in minimum number of tries")
                    SliderTextView(
                        range: -5 ... 20,
                        step: 1,
                        placeholder: "0",
                        formatter: MAFormatters.fmtChangeInMinIteration,
                        helpText: "Enter a value for the change in the minimum number of iterations in the image. This will change the coloring.",
                        value: $appState.picdef.dFIterMin
                    )
                }
                
                // nBlocks
                VStack(spacing: 10) {
                    Text("Number of Color Blocks")
                    SliderTextView(
                        range: 10 ... 100,
                        step: 10,
                        placeholder: "60",
                        formatter: MAFormatters.fmtNBlocks,
                        helpText: "Enter a value for the number of blocks of color in the image.",
                        value: Binding(
                            get: { Double(appState.picdef.nBlocks) },
                            set: { appState.picdef.nBlocks = Int($0) }
                        )
                    )
                }
                
                // Hold fraction with Slider
                HStack {
                    Text("Hold fraction")
                }
                HStack {
                    Text("0")
                    Slider(value: $appState.picdef.yY, in: 0 ... 1, step: 0.1)
                        .help(
                            "Enter a value for the fraction of a block of colors that will be a solid color before the rest is a gradient."
                        )
                    Text("1")
                    
                    TextField(
                        "0",
                        value: $appState.picdef.yY,
                        formatter: MAFormatters.fmtHoldFractionGradient
                    )
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 50)
                    .help(
                        "Enter a value for the fraction of a block of colors that will be a solid color before the rest is a gradient."
                    )
                }
                .padding(.horizontal)
                // END Hold fraction with Slider
                
                Spacer()
            } //  vstack
        } // scrollview
        .padding()
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
}
