import SwiftUI
import SwiftData
import UniformTypeIdentifiers

@available(macOS 12.0, *)
struct TabColor: View {
    @Binding var picdef: PictureDefinition
    @ObservedObject var popupManager: PopupManager
    @Binding var requiresFullCalc: Bool
    @Binding var showGradient: Bool
    @State private var didChange = false
    
    private var mandColorBinding: Binding<Color> {
        Binding<Color>(
            get: {
                // Convert Hue to Color
                Color(
                    red: picdef.mandColor.r / 255,
                    green: picdef.mandColor.g / 255,
                    blue: picdef.mandColor.b / 255
                )
            },
            set: {
                // Convert Color to Hue.
                let components = $0.cgColor?.components
                let red = (components?[0] ?? 0) * 255
                let green = (components?[1] ?? 0) * 255
                let blue = (components?[2] ?? 0) * 255
                picdef.mandColor = Hue(num: picdef.mandColor.num, r: red, g: green, b: blue)
            }
        )
    }
    
    func updateArt() {
        for (index, _) in picdef.hues.enumerated() {
            picdef.hues[index].num = index + 1
        }
        didChange.toggle()
    }
    
    var calculatedRightNumber: Int {
        if picdef.leftNumber >= 1 && picdef.leftNumber < picdef.hues.count {
            return picdef.leftNumber + 1
        }
        return 1
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Section(
                    header:
                        Text("Choose Your Colors")
                        .font(.headline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                ) {
                    HStack {
                        Text("Choose Color for Mandelbrot Set:")
                        ColorPicker("", selection: mandColorBinding, supportsOpacity: false)
                    }
                    
                    HStack {
                        Button("Add New Color") {
                            guard let modelContext = picdef.modelContext else {
                                print("Error: No SwiftData context found!")
                                return
                            }
                            
                            // Create a new Hue with a default color (black or white)
                            let newHue = Hue(num: picdef.hues.count + 1, r: 0, g: 0, b: 0) // Defaults to black
                            
                            // Insert into SwiftData context **before** modifying picdef.hues
                            modelContext.insert(newHue)
                            
                            Task {
                                await MainActor.run {
                                    // Insert into SwiftData context before modifying picdef.hues
                                    modelContext.insert(newHue)
                                    
                                    // Append the new color to the end of the list
                                    picdef.hues.append(newHue)
                                    
                                    // Ensure the numbers are correctly updated
                                    updateArt()
                                }
             
                            }
                            
                            
                            // Save changes to SwiftData
                            do {
                                try modelContext.save()
                                print("Successfully saved new hue. Total hues:", picdef.hues.count)

                            } catch {
                                print("Error saving new hue: \(error)")
                            }
                        }
                        .help("Add a new color.")
                        .padding([.bottom], 2)
                    }
                    
                    TabColorList(picdef: $picdef,  requiresFullCalc: $requiresFullCalc, showGradient: $showGradient)
                        .background(Color.red.opacity(0.5))
                        .frame(height: 300)
                } //  section
                
                Section(
                    header:
                        Text("Test Gradient between Adjacent Colors")
                        .font(.headline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical)
                    
                ) {
                    HStack {
                        Text("From:")
                            .help("Choose the left color number.")
                        
                        Picker("Select a color number", selection: $picdef.leftNumber) {
                            ForEach(1 ..< picdef.hues.count + 1, id: \.self) { index in
                                Text("\(index)")
                            }
                        }
                        .frame(maxWidth: 50)
                        .labelsHidden()
                        .help("Select the color number for the left side of a gradient.")
                        .onChange(of: picdef.leftNumber) { _,_ in
                            showGradient = true
                        }
                        
                        Text("to \(calculatedRightNumber)")
                            .help("The color number for the right side of a gradient.")
                        
                        Button("Display Gradient") {
                            showGradient = true
                        }
                        .help("Display a gradient to review the transition between adjoining colors.")
                        
                        Button("Display Art") {
                            showGradient = false
                        }
                        .help("Display art again after checking gradients.")
                    } //  hstack
                } //  section
                
                Divider()
                
                Section(
                    header:
                        Text("")
                        .font(.headline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                    
                ) {
                    VStack(alignment: .leading) {
                        Text("Click and drag a color number to reorder.")
                        Text("Click on a color to modify.")
                        Text("Click \(Image(systemName: "exclamationmark.circle")) to learn more.")
                    }
                    
                    TabSavePopup(popupManager: popupManager)
                } //  section
                
                Spacer() // Pushes everything above it up
            } //  vstack
        } //  scrollview
        .onAppear {
            showGradient = false
            requiresFullCalc = false
        }
        .onDisappear {
            if showGradient {
                showGradient = false
            }
        }
    }
}
