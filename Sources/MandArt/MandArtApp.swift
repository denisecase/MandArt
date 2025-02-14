import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import AppKit

@main
struct MandArtApp: App {
    @StateObject var appState: AppState
    
    init() {
        // Synchronously initialize SwiftData to obtain a valid container and a non‑optional picdef.
        do {
            let result = try MandArtApp.initializeSwiftDataSync()
            let state = AppState()
            state.modelContainer = result.container
            state.picdef = result.picdef  // Now non‑optional
            _appState = StateObject(wrappedValue: state)
        } catch {
            fatalError("Failed to initialize SwiftData: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(appState)
                .task {
                    await initializeSwiftData()
                }
        }
        .defaultSize(width: windowWidth, height: windowHeight)
        .commands {
            appMenuCommands(appState: appState)
        }
    }
    
    static func initializeSwiftDataSync() throws -> (container: ModelContainer, picdef: PictureDefinition) {
        let schema = Schema([PictureDefinition.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: false)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = container.mainContext
        
        var existingPicdefs = try context.fetch(FetchDescriptor<PictureDefinition>())
        
        if existingPicdefs.isEmpty {
            print("🔹 No saved MandArt found. Creating and saving default.")
            let newPicdef = PictureDefinition()
            context.insert(newPicdef) // Save new default
            try context.save()
            existingPicdefs.append(newPicdef)
        } else {
            print("Loaded last MandArt from SwiftData: \(existingPicdefs.first!.id)")
        }
        
        return (container, existingPicdefs.first!) // Always return the latest MandArt
    }


    
    /// Asynchronously ensures SwiftData is up to date.
    @MainActor
    private func initializeSwiftData() async {
        do {
            let schema = Schema([PictureDefinition.self])
            let configuration = ModelConfiguration(isStoredInMemoryOnly: false)
            let container = try ModelContainer(for: schema, configurations: [configuration])
            let context = container.mainContext
            
            // Fetch the last stored PictureDefinition
            var existingPicdefs = try context.fetch(FetchDescriptor<PictureDefinition>())
            
            if let lastUsedPicdef = existingPicdefs.first {
                print("Using saved MandArt: \(lastUsedPicdef.id)")
                self.appState.picdef = lastUsedPicdef
            } else {
                print("🔹 No saved MandArt found in async init. Creating default.")
                let newPicdef = PictureDefinition()
                context.insert(newPicdef) // Insert new default MandArt
                try context.save() // Save to SwiftData
                
                self.appState.picdef = newPicdef // Ensure appState matches
            }
            
            self.appState.modelContainer = container // Store SwiftData container in appState
            
        } catch {
            fatalError("Failed to initialize SwiftData: \(error)")
        }
    }

    
    // MARK: - App Constants and Window Size Calculations
    
    enum AppConstants {
        static let defaultOpeningWidth: CGFloat = 800.0
        static let defaultOpeningHeight: CGFloat = 600.0
        static let defaultPercentWidth: CGFloat = 0.8
        static let defaultPercentHeight: CGFloat = 0.8
        static let dockAndPreviewsWidth: CGFloat = 200.0
        static let heightMargin: CGFloat = 50.0
        
        static func defaultWidth() -> CGFloat {
            if let screenWidth = NSScreen.main?.visibleFrame.width {
                return min(screenWidth * defaultPercentWidth, screenWidth - dockAndPreviewsWidth)
            }
            return defaultOpeningWidth
        }
        
        static func defaultHeight() -> CGFloat {
            if let screenHeight = NSScreen.main?.visibleFrame.height {
                return screenHeight * defaultPercentHeight
            }
            return defaultOpeningHeight
        }
        
        static func maxDocumentWidth() -> CGFloat {
            if let screenWidth = NSScreen.main?.visibleFrame.width {
                return screenWidth - dockAndPreviewsWidth
            }
            return defaultOpeningWidth
        }
        
        static func maxDocumentHeight() -> CGFloat {
            if let screenHeight = NSScreen.main?.visibleFrame.height {
                return screenHeight - heightMargin
            }
            return defaultOpeningHeight
        }
    }
    
    private var screenSize: CGSize {
        NSScreen.main?.frame.size ?? CGSize(width: 1440, height: 900)
    }
    private var windowWidth: CGFloat {
        max(1000, screenSize.width * 0.85)
    }
    private var windowHeight: CGFloat {
        screenSize.height * 0.9
    }
}
