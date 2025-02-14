import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct TabColor: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var popupManager: PopupManager
    @State private var didChange = false
    
    private var mandColorBinding: Binding<Color> {
        Binding<Color>(
            get: {
                // Convert Hue to Color
                Color(
                    red: appState.picdef.mandColor.r / 255,
                    green: appState.picdef.mandColor.g / 255,
                    blue: appState.picdef.mandColor.b / 255
                )
            },
            set: {
                // Convert Color to Hue.
                let components = $0.cgColor?.components
                let red = (components?[0] ?? 0) * 255
                let green = (components?[1] ?? 0) * 255
                let blue = (components?[2] ?? 0) * 255
                appState.picdef.mandColor = Hue(num: appState.picdef.mandColor.num, r: red, g: green, b: blue)
            }
        )
    }
    
    func updateArt() {
        for (index, _) in appState.picdef.hues.enumerated() {
            appState.picdef.hues[index].num = index + 1
        }
        didChange.toggle()
    }
    
    var calculatedRightNumber: Int {
        if appState.picdef.leftNumber >= 1 && appState.picdef.leftNumber < appState.picdef.hues.count {
            return appState.picdef.leftNumber + 1
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
                            guard let modelContext = appState.picdef.modelContext else {
                                print("Error: No SwiftData context found!")
                                return
                            }
                            
                            Task {
                                await MainActor.run {
                                    // Create and insert the new hue in the SwiftData context FIRST
                                    let newHue = Hue(num: appState.picdef.hues.count + 1, r: 0, g: 0, b: 0)
                                    modelContext.insert(newHue)
                                    
                                    do {
                                        // Save immediately to persist the object
                                        try modelContext.save()
                                        print("New hue saved: \(newHue)")
                                        
                                        // Now append the persisted hue to `picdef.hues`
                                        appState.picdef.hues.append(newHue)
                                        
                                        // Ensure UI updates
                                        appState.objectWillChange.send()
                                        
                                    } catch {
                                        print("Error saving new hue: \(error)")
                                    }
                                }
                            }

                        }
                        .help("Add a new color.")
                        .padding([.bottom], 2)
                    }
                    
                    TabColorList().environmentObject(appState)
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
                        
                        Picker("Select a color number", selection: $appState.picdef.leftNumber) {
                            ForEach(1 ..< appState.picdef.hues.count + 1, id: \.self) { index in
                                Text("\(index)")
                            }
                        }
                        .frame(maxWidth: 50)
                        .labelsHidden()
                        .help("Select the color number for the left side of a gradient.")
                        .onChange(of: appState.picdef.leftNumber) { _,_ in
                            appState.updateShowGradient(true)
                        }
                        
                        Text("to \(calculatedRightNumber)")
                            .help("The color number for the right side of a gradient.")
                        
                        Button("Display Gradient") {
                            appState.updateShowGradient(true)
                        }
                        .help("Display a gradient to review the transition between adjoining colors.")
                        
                        Button("Display Art") {
                            appState.updateShowGradient(false)
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
            appState.updateShowGradient(false)
            appState.updateRequiresFullCalc(false)
        }
        .onDisappear {
            if appState.showGradient {
                appState.updateShowGradient(false)
            }
        }
    }
}
