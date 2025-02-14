import SwiftUI
import UniformTypeIdentifiers

@available(macOS 12.0, *)
struct TabFindImageSize: View {
    @Binding var picdef: PictureDefinition
    @Binding var requiresFullCalc: Bool
    
    func aspectRatio() -> Double {
        let h = Double(picdef.imageHeight)
        let w = Double(picdef.imageWidth)
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
                        value: $picdef.imageWidth,
                        formatter: MAFormatters.fmtImageWidthHeight
                    )
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 80)
                    .padding(10)
                    .help("Enter the width, in pixels, of the picture.")
                    .onChange(of: picdef.imageWidth) { _ , _ in
                        requiresFullCalc = true
                    }
                } // end vstack
                
                VStack {
                    Text("Height, px")
                    DelayedTextFieldInt(
                        placeholder: "1000",
                        value: $picdef.imageHeight,
                        formatter: MAFormatters.fmtImageWidthHeight
                    )
                    .frame(maxWidth: 80)
                    .padding(10)
                    .help("Enter the height, in pixels, of the picture.")
                    .onChange(of: picdef.imageHeight) { _ , _ in
                        requiresFullCalc = true
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
