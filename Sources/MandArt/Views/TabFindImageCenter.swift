import SwiftUI
import UniformTypeIdentifiers

struct TabFindImageCenter: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Section(
            header:
                Text("Set Picture Center")
                .font(.headline)
                .fontWeight(.medium)
                .padding(.vertical)
            
        ) {
            HStack {
                VStack { // vertical container
                    Text("Enter horizontal center")
                    Text("Between -2 and 2")
                    DelayedTextFieldDouble(
                        placeholder: "-0.75",
                        value: $appState.picdef.xCenter,
                        formatter: MAFormatters.fmtXY
                    )
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 170)
                    .help(
                        "Enter horizontal center of the picture. Recommended: If you plan to use a power > 2, you might change to 0.0 to start."
                    )
                    .onChange(of: appState.picdef.xCenter) { _, _ in
                        appState.updateRequiresFullCalc(true)
                    }
                } // end vstack
                
                VStack { //  vertical container
                    Text("Enter vertical center")
                    Text("Between -2 and 2")
                    DelayedTextFieldDouble(
                        placeholder: "0.0",
                        value: $appState.picdef.yCenter,
                        formatter: MAFormatters.fmtXY
                    )
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 170)
                    .help("Enter vertical center of the picture.")
                    .onChange(of: appState.picdef.xCenter) { _, _ in
                        appState.requiresFullCalc = true
                    }
                }
            } // end HStack for XY
        }
        Divider()
    }
}
