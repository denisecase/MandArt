import SwiftData
import Foundation

/// **Manages SwiftData persistence for `PictureDefinition`.**
struct PersistenceManager {
    
    /// **Initializes SwiftData and loads the last saved `PictureDefinition`.**
    @MainActor
    static func initializeSwiftData() throws -> (container: ModelContainer, picdef: PictureDefinition) {
        let schema = Schema([PictureDefinition.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: false)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = container.mainContext
        
        // Fetch existing saved MandArt
        let existingPicdefs = try context.fetch(FetchDescriptor<PictureDefinition>())
        
        if let lastSavedPicdef = existingPicdefs.first {
            print("Loaded last saved MandArt settings.")
            return (container, lastSavedPicdef)
        } else {
            // No saved instance found → Create a new default one
            let newPicdef = PictureDefinition()
            context.insert(newPicdef)
            try context.save()
            print("Created & saved new default MandArt.")
            return (container, newPicdef)
        }
    }
}
