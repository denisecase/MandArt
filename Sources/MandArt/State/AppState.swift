import SwiftUI
import SwiftData
import AppKit // for rendered image

/// `AppState` is a class that holds the application's state.
/// It observes changes and updates the UI accordingly.
@MainActor
class AppState: ObservableObject {

    @Published var picdef: PictureDefinition {
        didSet {
            print("picdef UPDATED: \(picdef.id) at \(Date())")
        }}

    @Published var renderedImage: NSImage?
    @Published var requiresFullCalc: Bool = true
    @Published var showGradient: Bool = true
    @Published var showResetAlert: Bool = false
    @Published var showReplaceAlert: Bool = false
    @Published var pendingReplacement: (() -> Void)? = nil
    @Published var currentFileURL: URL? // Tracks the last opened/saved file


    var modelContainer: ModelContainer?
    
    /// Initializes the app state and loads the last used PictureDefinition.
    init() {
        do {
            let result = try AppState.initializeSwiftDataSync()
            self.modelContainer = result.container
            self.picdef = result.picdef
        } catch {
            fatalError("ERROR: Failed to initialize SwiftData: \(error)")
        }
        self.loadSavedMandArt()
    }

    func loadSavedMandArt() {
        if let lastOpenedPath = UserDefaults.standard.string(forKey: "lastOpenedFilePath") {
            let url = URL(fileURLWithPath: lastOpenedPath)
            if let data = try? Data(contentsOf: url),
               let loadedPicdef = try? JSONDecoder().decode(PictureDefinition.self, from: data) {
                print("SUCCESS: Loaded last opened MandArt from: \(url.path)")
                self.picdef = loadedPicdef
                self.currentFileURL = url
                return //Return early if a valid file is loaded
            }
        }
        // Fallback if no file was loaded
        print("WARNING: No saved MandArt found. Using default.")
        self.picdef = PictureDefinition()
        self.currentFileURL = nil
    }

    
    func updateCurrentFile(url: URL) {
        self.currentFileURL = url
        UserDefaults.standard.set(url.path, forKey: "lastOpenedFilePath") // Save persistently
        print("📂 Updated current file to: \(url.path)")
    }

    
    
    func updateRenderedImage(_ newImage: NSImage) {
        self.renderedImage = newImage
    }
    
    func updateRequiresFullCalc(_ newValue: Bool) {
        self.requiresFullCalc = newValue
    }
    
    func updateShowGradient(_ newValue: Bool) {
        self.showGradient = newValue
    }
    
    @MainActor
    func resetMandArt() {
        print("Resetting MandArt to default.")
        
        guard let container = modelContainer else {
            print("SwiftData container is missing!")
            return
        }
        
        let context = container.mainContext
        
        // Delete all old instances to prevent conflicts
        let existingPicdefs = try? context.fetch(FetchDescriptor<PictureDefinition>())
        existingPicdefs?.forEach { context.delete($0) }
        
        // Create a new default MandArt
        let newPicdef = PictureDefinition()
        context.insert(newPicdef) // Add new instance to SwiftData
        
        do {
            try context.save() // Persist changes
            self.picdef = newPicdef // Ensure appState reflects the reset state
            print("Saved new default MandArt: \(newPicdef.id)")
        } catch {
            print("Error resetting MandArt: \(error)")
        }
    }


    
    func promptReplaceMandArt(action: @escaping () -> Void) {
        self.pendingReplacement = action
        self.showReplaceAlert = true
    }
    
    func confirmReplaceMandArt() {
        if let action = pendingReplacement {
            action()
            pendingReplacement = nil
        }
    }
    
    func replaceMandArt() {
        print("CAUTION: Replacing current MandArt.")
        promptReplaceMandArt { [weak self] in
            guard let self = self else { return }
            if let container = modelContainer {
                let context = container.mainContext
                let newPicdef = PictureDefinition()
                context.insert(newPicdef)
                do {
                    try context.save()
                    self.picdef = newPicdef
                } catch {
                    print("Error replacing MandArt: \(error)")
                }
            }
        }
    }
    
    
    /// Ensures SwiftData loads the last saved PictureDefinition or creates one if none exist.
    static func initializeSwiftDataSync() throws -> (container: ModelContainer, picdef: PictureDefinition) {
        let schema = Schema([PictureDefinition.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: false)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = container.mainContext
        
        // Always fetch from SwiftData first
        let existingPicdefs = try context.fetch(FetchDescriptor<PictureDefinition>())
        
        if let lastSavedPicdef = existingPicdefs.first {
            print("Loaded last saved MandArt settings.")
            return (container, lastSavedPicdef)  // Always return the saved one
        } else {
            // No saved instance exists → Create a default one
            let newPicdef = PictureDefinition()
            context.insert(newPicdef)
            try context.save()
            print("🆕 Created and saved a brand-new default MandArt.")
            return (container, newPicdef)
        }
    }

}
