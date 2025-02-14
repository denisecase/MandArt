import SwiftUI
import UniformTypeIdentifiers
import AppKit

struct TabSave: View {
    @Binding var picdef: PictureDefinition
    @ObservedObject var popupManager = PopupManager()
    @Binding var requiresFullCalc: Bool
    @Binding var showGradient: Bool
    
    var body: some View {
        ScrollView {
            VStack {
                Section(
                    header:
                        Text("Save Your Art")
                        .font(.headline)
                        .fontWeight(.medium)
                        .padding(.vertical)
                ) {
                    Button("Save Picture Inputs (as data file)") {
                        picdef.saveMandArtImageInputs()
                    }
                    .help("Save MandArt picture inputs as .mandart.")
                    
                    Button("Save Picture (as .png)") {
                        if let image = generateNSImage() {
                            picdef.saveMandArtImage(image: image)
                        } else {
                            print("Error: Could not generate image")
                        }
                    }
                    .help("Save MandArt picture as .png.")
                } // end section
            } //  vstack
        } // scroll
        .onAppear {
            requiresFullCalc = false
            showGradient = false
        }
        .onDisappear {
            if requiresFullCalc {
                requiresFullCalc = false
            }
        }
    }
    
    /// **Generates an NSImage from the current MandArt view**
    private func generateNSImage() -> NSImage? {
        let size = NSSize(width: picdef.imageWidth, height: picdef.imageHeight)
        let image = NSImage(size: size)
        
        image.lockFocus() // Start drawing
        NSColor.white.setFill()
        NSRect(origin: .zero, size: size).fill() // Fill background
        
        // Example: Draw a rectangle with the primary hue color
        if let firstHue = picdef.hues.first {
            let color = NSColor(red: firstHue.r / 255, green: firstHue.g / 255, blue: firstHue.b / 255, alpha: 1)
            color.setFill()
            NSRect(x: 10, y: 10, width: size.width - 20, height: size.height - 20).fill()
        }
        
        image.unlockFocus() // Stop drawing
        
        return image
    }
    
    
    
    
}


enum MandArtError: LocalizedError {
    case encodingError
    case emptyData
    case failedSaving
    
    var errorDescription: String? {
        switch self {
        case .encodingError:
            return "Error encoding picdef."
        case .emptyData:
            return "Encoded data is empty."
        case .failedSaving:
            return "Failed to save picture inputs."
        }
    }
}

