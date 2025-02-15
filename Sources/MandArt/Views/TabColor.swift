import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct TabColor: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var popupManager: PopupManager
    @State private var didChange = false
    
    /// **Binding for Mandelbrot Set Color**
    private var mandColorBinding: Binding<Color> {
        Binding<Color>(
            get: {
                appState.picdef.mandColor.color // Use computed Color from Hue
            },
            set: { newColor in
                appState.picdef.updateMandColor(to: newColor)
            }
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Section(header: Text("Choose Your Colors").font(.headline).frame(maxWidth: .infinity, alignment: .center)) {
                    
                    HStack {
                        Text("Choose Color for Mandelbrot Set:")
                        ColorPicker("", selection: mandColorBinding, supportsOpacity: false)
                    }
                    
                    HStack {
                        Button("Add New Color") {
                            appState.picdef.addHue(undoManager: appState.undoManager)
                            didChange.toggle() // Ensure UI updates
                        }
                        .help("Add a new color.")
                        .padding(.bottom, 2)
                    }
                    
                    TabColorList()
                        .environmentObject(appState)
                        .background(Color.red.opacity(0.5))
                        .frame(height: 300)
                }
                
                Section(header: Text("Test Gradient between Adjacent Colors").font(.headline).frame(maxWidth: .infinity, alignment: .center).padding(.vertical)) {
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
                        
                        Text("to \(appState.picdef.calculatedRightNumber)")
                            .help("The color number for the right side of a gradient.")
                        
                        Button("Display Gradient") {
                            appState.updateShowGradient(true)
                        }
                        .help("Display a gradient to review the transition between adjoining colors.")
                        
                        Button("Display Art") {
                            appState.updateShowGradient(false)
                        }
                        .help("Display art again after checking gradients.")
                    }
                }
                
                Divider()
                
                Section(header: Text("").font(.headline).frame(maxWidth: .infinity)) {
                    VStack(alignment: .leading) {
                        Text("Click and drag a color number to reorder.")
                        Text("Click on a color to modify.")
                        Text("Click \(Image(systemName: "exclamationmark.circle")) to learn more.")
                    }
                    
                    TabSavePopup(popupManager: popupManager)
                }
                
                Spacer()
            }
        }
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
