import SwiftUI
import UniformTypeIdentifiers

@available(macOS 12.0, *)
struct TabFindScale: View {
    @Binding var picdef: PictureDefinition
    @Binding var requiresFullCalc: Bool
    
    @State private var localScale: Double = 1.0
    @State private var scaleMultiplier: Double = 5.0
    @State private var scaleString: String = ""
    
    init(picdef: Binding<PictureDefinition>, requiresFullCalc: Binding<Bool>) {
        self._picdef = picdef
        self._requiresFullCalc = requiresFullCalc
        let initialScale = picdef.wrappedValue.scale
        self._localScale = State(initialValue: initialScale)
        self._scaleString = State(initialValue: initialScale.customFormattedString())
    }
    
    /// Safely updates the scale, only if `picdef` is still valid.
    private func updateScale(newScale: Double) {
        localScale = newScale
        scaleString = newScale.customFormattedString()
        requiresFullCalc = true
        
        Task {
            guard let modelContext = picdef.modelContext else {
                print("⚠️ Skipping update: picdef is no longer valid.")
                return
            }
            do {
                picdef.scale = localScale
                try modelContext.save()
            } catch {
                print("Error saving updated scale: \(error)")
            }
        }
    }
    
    var body: some View {
        Section(header: Text("Set Magnification").font(.headline)) {
            HStack {
                TextField("", text: $scaleString, onCommit: {
                    if let newScale = Double(scaleString) {
                        updateScale(newScale: newScale)
                    }
                })
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 180)
                .help("Enter the magnification (may take a while).")
                .onAppear {
                    if let context = picdef.modelContext {
                        scaleString = picdef.scale.customFormattedString()
                    } else {
                        print("picdef lost context onAppear")
                    }
                }
                .onChange(of: picdef.scale) { _, newValue in
                    if let context = picdef.modelContext {
                        scaleString = newValue.customFormattedString()
                    } else {
                        print("picdef lost context onChange")
                    }
                }
            }
            .padding(.horizontal)
            
            HStack {
                VStack {
                    Text("Zoom By 2")
                    HStack {
                        Button("+") { updateScale(newScale: localScale * 2.0) }
                        Text("2")
                        Button("-") { updateScale(newScale: localScale / 2.0) }
                    }
                }
                Divider()
                VStack {
                    Text("Custom Zoom")
                    HStack {
                        Button("+") { updateScale(newScale: localScale * scaleMultiplier) }
                        TextField("", text: Binding(
                            get: { "\(scaleMultiplier)" },
                            set: { newValue in
                                if let newMultiplier = Double(newValue) {
                                    scaleMultiplier = max(1.0001, min(10.0, newMultiplier)) // Keep in range
                                }
                            }
                        ), onCommit: {
                            scaleMultiplier = max(1.0001, min(10.0, scaleMultiplier))
                        })
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.trailing)
                        .frame(minWidth: 70, maxWidth: 90)
                        .help("Maximum value of 10.")
                        Button("-") { updateScale(newScale: localScale / scaleMultiplier) }
                    }
                }
            }
        }
    }
}
