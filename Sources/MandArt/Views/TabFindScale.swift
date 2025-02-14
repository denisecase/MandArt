import SwiftUI
import UniformTypeIdentifiers

struct TabFindScale: View {
    @EnvironmentObject var appState: AppState
    @State private var localScale: Double = 1.0
    @State private var scaleMultiplier: Double = 5.0
    @State private var scaleString: String = ""
    
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
                    // Initialize localScale and scaleString from appState.picdef when the view appears.
                    localScale = appState.picdef.scale
                    scaleString = appState.picdef.scale.customFormattedString()
                }
                .onChange(of: appState.picdef.scale) { _, newValue in
                    scaleString = newValue.customFormattedString()
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
                                    scaleMultiplier = max(1.0001, min(10.0, newMultiplier))
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
    
    /// Safely updates the scale, only if `picdef` is still valid.
    private func updateScale(newScale: Double) {
        localScale = newScale
        scaleString = newScale.customFormattedString()
        appState.updateRequiresFullCalc(true)
        
        Task {
            guard let modelContext = appState.picdef.modelContext else {
                print("Skipping update: picdef is no longer valid.")
                return
            }
            do {
                appState.picdef.scale = localScale
                try modelContext.save()
            } catch {
                print("Error saving updated scale: \(error)")
            }
        }
    }
}
