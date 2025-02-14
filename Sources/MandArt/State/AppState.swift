import SwiftUI
import SwiftData
import AppKit // for rendered image

/// `AppState` is a class that holds the application's state.
/// It observes changes and updates the UI accordingly.
@MainActor
class AppState: ObservableObject {

    @Published var picdef: PictureDefinition
    @Published var renderedImage: NSImage?
    @Published var requiresFullCalc: Bool = true
    @Published var showGradient: Bool = true
    @Published var showResetAlert: Bool = false
    @Published var showReplaceAlert: Bool = false
    @Published var pendingReplacement: (() -> Void)? = nil

    var modelContainer: ModelContainer?
    
    /// Initializes the app state and loads the last used PictureDefinition.
    init() {
        do {
            let result = try AppState.initializeSwiftDataSync()
            self.modelContainer = result.container
            self.picdef = result.picdef
        } catch {
            fatalError("Failed to initialize SwiftData: \(error)")
        }
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
    
    func resetMandArt() {
        print("CAUTION: Resetting MandArt to default state.")
        if let container = modelContainer {
            let context = container.mainContext
            let newPicdef = PictureDefinition()
            context.insert(newPicdef)
            do {
                try context.save()
                self.picdef = newPicdef
            } catch {
                print("Error resetting MandArt: \(error)")
            }
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
    
    
    /// **SwiftData Initialization**
    static func initializeSwiftDataSync() throws -> (container: ModelContainer, picdef: PictureDefinition) {
        let schema = Schema([PictureDefinition.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: false)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = container.mainContext
        
        var existingPicdefs = try context.fetch(FetchDescriptor<PictureDefinition>())
        if existingPicdefs.isEmpty {
            let newPicdef = PictureDefinition()
            context.insert(newPicdef)
            try context.save()
            existingPicdefs.append(newPicdef)
        }
        return (container, existingPicdefs.first!)
    }
}
