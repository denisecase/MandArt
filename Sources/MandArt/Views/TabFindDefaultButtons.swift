import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct TabFindDefaultButtons: View {
    @Binding var picdef: PictureDefinition
    @Binding var requiresFullCalc: Bool
    @State private var didChange: Bool = false
    
    init(picdef: Binding<PictureDefinition>, requiresFullCalc: Binding<Bool>) {
        _picdef = picdef
        _requiresFullCalc = requiresFullCalc
    }
    
    func showDefaultMandArt(mandPowerReal: Int) {
        if mandPowerReal == 2 {
            picdef.imageWidth = 1100
            picdef.imageHeight = 1000
            picdef.xCenter = -0.75
            picdef.yCenter = 0.0
            picdef.theta = 0.0
            picdef.scale = 430.0
            picdef.iterationsMax = 10000.0
            picdef.rSqLimit = 500.0
            
        } else if mandPowerReal == 3 {
            picdef.imageWidth = 1100
            picdef.imageHeight = 1000
            picdef.xCenter = 0.0
            picdef.yCenter = 0.0
            picdef.theta = 0.0
            picdef.iterationsMax = 10000.0
            picdef.scale = 360.0
            picdef.rSqLimit = 64.0
        }
        
        else {
            picdef.imageWidth = 1100
            picdef.imageHeight = 1000
            picdef.xCenter = 0.0
            picdef.yCenter = 0
            picdef.theta = 0.0
            picdef.iterationsMax = 50.0
            picdef.scale = 430.0
            picdef.rSqLimit = 25.0
        }
        picdef.mandPowerReal = mandPowerReal
        //  picdef.mandPowerImaginary = 0.0
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
                Button("MandArt5") { showDefaultMandArt(mandPowerReal: 5) }
                    .help("Like the Mandelbrot Set, but uses an exponent of 5.")
                Button("MandArt6") { showDefaultMandArt(mandPowerReal: 6) }
                    .help("Like the Mandelbrot Set, but uses an exponent of 6.")
                Button("MandArt7") { showDefaultMandArt(mandPowerReal: 7) }
                    .help("Like the Mandelbrot Set, but uses an exponent of 7.")
            }
            HStack {
                Button("MandArt8") { showDefaultMandArt(mandPowerReal: 8) }
                    .help("Like the Mandelbrot Set, but uses an exponent of 8.")
                Button("MandArt9") { showDefaultMandArt(mandPowerReal: 9) }
                    .help("Like the Mandelbrot Set, but uses an exponent of 9.")
                Button("MandArt10") { showDefaultMandArt(mandPowerReal: 10) }
                    .help("Like the Mandelbrot Set, but uses an exponent of 10.")
            }
            HStack {
                Button("MandArt11") { showDefaultMandArt(mandPowerReal: 11) }
                    .help("Like the Mandelbrot Set, but uses an exponent of 11.")
                Button("MandArt12") { showDefaultMandArt(mandPowerReal: 12) }
                    .help("Like the Mandelbrot Set, but uses an exponent of 12.")
            }
            .padding(.bottom)
        }
        Divider()
    }
}
