import AppKit // keypress
import CoreGraphics // for image scrollview?
import Foundation // trig functions
import SwiftUI // views
import UniformTypeIdentifiers
import SwiftData

// Global variable to hold a reference to the CGImage used across the app
var contextImageGlobal: CGImage?

/// `ContentView` is the main view of the MandArt application, available on macOS 14.0 and later.
/// It provides the user interface for interacting with the Mandelbrot set art generation features of the app.
struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var modelContext
    @Query private var picdefs: [PictureDefinition]
    @StateObject var popupManager = PopupManager()
    @State var requiresFullCalc = true
    @State var showGradient: Bool = false
    
    @State private var moved: Double = 0.0
    @State private var startTime: Date?
    @State private var previousPicdef: PictureDefinition?
    @State private var textFieldImageHeight: NSTextField = .init()
    @State private var textFieldY: NSTextField = .init()
    private let widthOfInputPanel: CGFloat = 400
    
    var body: some View {
        GeometryReader { _ in
            HStack(spacing: 0) {
                if let picdef = picdefs.first {
                    PanelUI(
                        picdef: Binding(
                            get: { picdef },
                            set: { newValue in
                                updatePicdef(picdef, with: newValue)
                            }
                        ),
                        popupManager: popupManager,
                        requiresFullCalc: $requiresFullCalc,
                        showGradient: $showGradient
                    )
                    .frame(width: widthOfInputPanel)
                    .fixedSize(horizontal: true, vertical: false)
                    
                    PanelDisplay(
                        picdef: Binding(
                            get: { picdef },
                            set: { newValue in
                                updatePicdef(picdef, with: newValue)
                            }
                        ),
                        requiresFullCalc: $requiresFullCalc,
                        showGradient: $showGradient
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Text("No MandArt document found. Creating a new one...")
                        .onAppear {
                            createDefaultPictureDefinition()
                        }
                }
            }
            .overlay(
                Group {
                    if let picdef = picdefs.first {
                        ContentViewPopups(
                            picdef: Binding(
                                get: { picdef },
                                set: { newValue in
                                    updatePicdef(picdef, with: newValue)
                                }
                            ),
                            popupManager: popupManager,
                            requiresFullCalc: $requiresFullCalc
                        )
                    }
                }
            )
            
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.leading, 0)
        } // geo
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    } // body
    
    /// Ensures at least one `PictureDefinition` exists
    private func checkAndCreateDefaultPicdef() {
        if picdefs.isEmpty {
            addNewPictureDefinition()
        }
    }
    
    /// Creates and inserts a new `PictureDefinition`
    private func addNewPictureDefinition() {
        let newPicdef = PictureDefinition()
        modelContext.insert(newPicdef)
    }
    
    /// Ensures at least one `PictureDefinition` exists before proceeding
    private func createDefaultPictureDefinition() {
        if picdefs.isEmpty {
            let newPicdef = PictureDefinition()
            modelContext.insert(newPicdef)
        }
    }
    
    /// Updates an existing `PictureDefinition`
    private func updatePicdef(_ oldPicdef: PictureDefinition, with newPicdef: PictureDefinition) {
        oldPicdef.hues = newPicdef.hues
        oldPicdef.leftNumber = newPicdef.leftNumber
        oldPicdef.mandColor = newPicdef.mandColor
        oldPicdef.scale = newPicdef.scale
        oldPicdef.theta = newPicdef.theta
        oldPicdef.iterationsMax = newPicdef.iterationsMax
    }
}
