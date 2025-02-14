import SwiftUI
import UniformTypeIdentifiers

@available(macOS 12.0, *)
struct TabFindImageSize: View {
    @EnvironmentObject var appState: AppState
    
    func aspectRatio() -> Double {
        let h = Double(appState.picdef.imageHeight)
        let w = Double(appState.picdef.imageWidth)
        return max(h / w, w / h)
    }
    
    var body: some View {
        Section(
            header:
                Text("Set Picture Size")
                .font(.headline)
                .fontWeight(.medium)
                .padding(.vertical)
            
        ) {
            HStack {
                VStack {
                    Text("Width, px")
                    DelayedTextFieldInt(
                        placeholder: "1100",
                        value: $appState.picdef.imageWidth,
                        formatter: MAFormatters.fmtImageWidthHeight
                    )
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 80)
                    .padding(10)
                    .help("Enter the width, in pixels, of the picture.")
                    .onChange(of: appState.picdef.imageWidth) { _ , _ in
                        appState.updateRequiresFullCalc(true)
                    }
                } // end vstack
                
                VStack {
                    Text("Height, px")
                    DelayedTextFieldInt(
                        placeholder: "1000",
                        value: $appState.picdef.imageHeight,
                        formatter: MAFormatters.fmtImageWidthHeight
                    )
                    .frame(maxWidth: 80)
                    .padding(10)
                    .help("Enter the height, in pixels, of the picture.")
                    .onChange(of: appState.picdef.imageHeight) { _ , _ in
                        appState.updateRequiresFullCalc(true)
                    }
                } // end vstack
                
                VStack {
                    Text("Aspect Ratio")
                    Text(String(format: "%.2f", aspectRatio()))
                        .padding(10)
                        .help("Calculated value of picture width over picture height.")
                }
            }
        }
        
        Divider()
    }
}
