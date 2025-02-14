import SwiftUI
import UniformTypeIdentifiers

/// A view representing a row in the color list.
struct TabColorListRow: View {
    @Binding var picdef: PictureDefinition
    @State private var showingPrintablePopups = false
    @State private var didChange = false
    
    let index: Int
    
    var rowNumber: Int {
        index + 1
    }
    
    var isIndexValid: Bool {
        picdef.hues.indices.contains(index)
    }
    
    /// Updates the hue numbers to match their position in the list.
    func updateHueNums() {
        DispatchQueue.main.async {
            for (i, _) in picdef.hues.enumerated() {
                picdef.hues[i].num = i + 1
            }
        }
    }
    
    /// Determines if a color is likely to print accurately.
    func getIsPrintable(color: Color) -> Bool {
        MandMath.isColorNearPrintableList(color: color.cgColor!, num: picdef.hues[index].num)
    }
    
    var body: some View {
        if isIndexValid {
            HStack {
                Image(systemName: "line.horizontal.3")
                    .foregroundColor(.secondary)
                
                Text(String(rowNumber))
                
                ColorPicker(
                    "",
                    selection: Binding<Color>(
                        get: {
                            if picdef.hues.indices.contains(index) {
                                return picdef.hues[index].color
                            } else {
                                return Color.white  // ✅ Provide default color if index is invalid
                            }
                        },
                        set: { newColor in
                            if picdef.hues.indices.contains(index), let components = newColor.cgColor?.components, components.count >= 3 {
                                var updatedHues = picdef.hues
                                updatedHues[index] = Hue(
                                    num: updatedHues[index].num,
                                    r: components[0] * 255.0,
                                    g: components[1] * 255.0,
                                    b: components[2] * 255.0
                                )
                                picdef.hues = updatedHues
                            }
                        }
                    ),
                    supportsOpacity: false
                )
                
                Button {
                    showingPrintablePopups = true
                } label: {
                    Image(systemName: "exclamationmark.circle")
                        .opacity(getIsPrintable(color: picdef.hues[index].color) ? 0 : 1)
                }
                .opacity(getIsPrintable(color: picdef.hues[index].color) ? 0 : 1)
                .help("See printable options for " + "\(rowNumber)")
                
                if showingPrintablePopups {
                    ZStack {
                        VStack {
                            Button(action: {
                                self.showingPrintablePopups = false
                            }) {
                                Image(systemName: "xmark.circle")
                            }
                            VStack {
                                Text("This color may not print well.")
                                Text("See the instructions for options.")
                            }
                        }
                    }
                    .frame(width: 150, height: 100)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .opacity(0.2)
                            .shadow(radius: 5, y: 5)
                    )
                }
                
                Text(String(format: "%03d", picdef.hues.indices.contains(index) ? Int(picdef.hues[index].r) : 255))
                Text(String(format: "%03d", picdef.hues.indices.contains(index) ? Int(picdef.hues[index].g) : 255))
                Text(String(format: "%03d", picdef.hues.indices.contains(index) ? Int(picdef.hues[index].b) : 255))

                
                Button(role: .destructive) {
                    var updatedHues = picdef.hues
                    
                    if updatedHues.indices.contains(index) {
                        updatedHues.remove(at: index)
                        picdef.hues = updatedHues
                        updateHueNums()
                        
                        // If hues is empty, insert a default hue to avoid empty state crash
                        if updatedHues.isEmpty {
                            let defaultHue = Hue(num: 1, r: 255, g: 255, b: 255) // Default to white
                            picdef.hues.append(defaultHue)
                        }
                    }
                }
                    label: {
                    Image(systemName: "trash")
                }
                .help("Delete " + "\(rowNumber)")
                
                Spacer()
            }
        }
    }
}
