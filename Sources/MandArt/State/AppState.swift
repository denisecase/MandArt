import SwiftUI
import SwiftData
import AppKit // for rendered image

/// **`AppState` manages the global application state.**
/// Handles UI state, file operations, and SwiftData interactions.
@MainActor
class AppState: ObservableObject {
    
    // MARK: - Core State Properties
    @Published var picdef: PictureDefinition {
        didSet {
            print("picdef updated: \(picdef) at \(Date())")
        }
    }
    @Published var undoManager: UndoManager = .init()
    @Published var modelContainer: ModelContainer?
    
    // MARK: - File Management
    @Published var currentFileURL: URL? // Tracks the last opened/saved file
    
    // MARK: - UI State Flags
    @Published var renderedImage: NSImage?
    @Published var requiresFullCalc: Bool = true
    @Published var showGradient: Bool = true
    @Published var showResetAlert: Bool = false
    @Published var showReplaceAlert: Bool = false
    
    // MARK: - Pending Actions
    @Published var pendingReplacement: (() -> Void)? = nil
    
    // MARK: - Initializer
    init() {
        do {
            let result = try PersistenceManager.initializeSwiftData()
            self.modelContainer = result.container
            self.picdef = result.picdef
            self.picdef.context = result.container.mainContext

        } catch {
            print("Failed to initialize SwiftData: \(error.localizedDescription). Using default.")
            self.modelContainer = nil
            self.picdef = PictureDefinition()
        }
        self.loadLastOpenedMandArt()
    }

    // MARK: - Save Function
    func saveToSwiftData() {
        guard let context = modelContainer?.mainContext else { return }
        do {
            try context.save()
            print("Successfully saved changes to SwiftData")
        } catch {
            print("Error saving SwiftData: \(error)")
        }
    }
}
