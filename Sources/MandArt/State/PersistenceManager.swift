import SwiftData

/// Manages SwiftData persistence for the app.
struct PersistenceManager {
    
    @MainActor
    static func initializeSwiftData() throws -> (container: ModelContainer, picdef: PictureDefinition) {
        let schema = Schema([PictureDefinition.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        let container = try ModelContainer(for: schema, configurations: config)
        
        // Try fetching the last stored PictureDefinition
        let fetchDescriptor = FetchDescriptor<PictureDefinition>(sortBy: [.init(\.id, order: .reverse)])
        
        if let lastSaved = try container.mainContext.fetch(fetchDescriptor).first {
            return (container, lastSaved)
        } else {
            // No existing record, create a new one
            let newPicDef = PictureDefinition()
            container.mainContext.insert(newPicDef)
            try container.mainContext.save()
            return (container, newPicDef)
        }
    }
}
