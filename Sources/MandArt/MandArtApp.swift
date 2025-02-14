import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import AppKit

/// `AppState` is a class that holds the application's state.
/// It observes changes and updates the UI accordingly.
class AppState: ObservableObject {
  @Published var shouldShowWelcomeWhenStartingUp: Bool = UserDefaults.standard
    .object(forKey: "shouldShowWelcomeWhenStartingUp") as? Bool ?? true
}

/// `WindowAccessor` is a SwiftUI view that allows access to the underlying NSWindow.
struct WindowAccessor: NSViewRepresentable {
  var callback: (NSWindow?) -> Void

  func makeNSView(context _: Context) -> NSView {
    let view = NSView()
    DispatchQueue.main.async {
      self.callback(view.window)
      if let window = view.window {
        let screenSize = NSScreen.main?.frame.size ?? CGSize(width: 800, height: 600)
        let width = screenSize.width * MandArtApp.AppConstants.defaultPercentWidth
        let height = screenSize.height * MandArtApp.AppConstants.defaultPercentHeight
        let x = (screenSize.width - width) / 2
        let y = (screenSize.height - height) / 2
        window.setFrame(NSRect(x: x, y: y, width: width, height: height), display: true)
      }
    }
    return view
  }

  func updateNSView(_: NSView, context _: Context) {}
}

/// `MandArtApp` is the main structure for the SwiftUI app.
/// It defines the behavior and layout of the app.
@main
struct MandArtApp: App {
    @StateObject var appState: AppState
    @State private var shouldShowWelcomeWhenStartingUp: Bool
    @State private var modelContainer: ModelContainer?
    
    
    init() {
        let initialState = UserDefaults.standard.object(forKey: "shouldShowWelcomeWhenStartingUp") as? Bool ?? true
        _appState = StateObject(wrappedValue: AppState())
        _shouldShowWelcomeWhenStartingUp = State(initialValue: initialState)
    }
    
    /// Ensures at least one `PictureDefinition` exists in SwiftData
    private func ensurePictureDefinitionExists(in context: ModelContext) {
        Task {
            let existingPicdefs = try? context.fetch(FetchDescriptor<PictureDefinition>())
            if existingPicdefs?.isEmpty ?? true {
                let newPicdef = PictureDefinition()
                context.insert(newPicdef)
                try? context.save() // Ensure it persists
            }
        }
    }
    
    /// Constants used across the app, such as dimensions and margins.
    enum AppConstants {
        static let defaultOpeningWidth: CGFloat = 800.0
        static let defaultOpeningHeight: CGFloat = 600.0
        static let defaultPercentWidth: CGFloat = 0.8
        static let defaultPercentHeight: CGFloat = 0.8
        static let dockAndPreviewsWidth: CGFloat = 200.0
        static let minWelcomeWidth: CGFloat = 500.0
        static let minWelcomeHeight: CGFloat = 500.0
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
        
        static func maxWelcomeWidth() -> CGFloat {
            if let screenWidth = NSScreen.main?.visibleFrame.width {
                return screenWidth * 0.66
            }
            return minWelcomeWidth
        }
        
        static func maxWelcomeHeight() -> CGFloat {
            if let screenHeight = NSScreen.main?.visibleFrame.height {
                return screenHeight * 0.8
            }
            return minWelcomeHeight
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
    
    
    /// **Window size calculations**
    private var screenSize: CGSize {
        NSScreen.main?.frame.size ?? CGSize(width: 1440, height: 900) // Default to a common screen size
    }
    private var windowWidth: CGFloat {
        max(1000, screenSize.width * 0.85) // Ensure it's at least 1000px wide
    }
    private var windowHeight: CGFloat {
        screenSize.height * 0.9 // Use 90% of the available height
    }
    
    
    
    /// The main body of the app, defining the views and their behavior.
    var body: some Scene {
        WindowGroup {
            Group {
                if shouldShowWelcomeWhenStartingUp {
                    WelcomeView()
                        .environmentObject(appState)
                } else if let modelContainer = modelContainer {
                    ContentView()
                        .environment(\.modelContext, modelContainer.mainContext)
                } else {
                    Text("Error: Unable to load data")
                }
            }
            .task {
                await initializeSwiftData()
            }
        }
        .defaultSize(width: windowWidth, height: windowHeight)
        .commands {
            appMenuCommands()
        }
    }
    
    /// **Ensure SwiftData container is initialized**
    private func initializeSwiftData() async {
        do {
            let schema = Schema([PictureDefinition.self])
            let configuration = ModelConfiguration(isStoredInMemoryOnly: false)
            let container = try ModelContainer(for: schema, configurations: [configuration])
            
            // Ensure at least one PictureDefinition exists
            let context = container.mainContext
            let existingPicdefs = try? context.fetch(FetchDescriptor<PictureDefinition>())
            if existingPicdefs?.isEmpty ?? true {
                let newPicdef = PictureDefinition()
                context.insert(newPicdef)
                try? context.save()
            }
            
            DispatchQueue.main.async {
                self.modelContainer = container
            }
        } catch {
            fatalError("Failed to initialize SwiftData: \(error)")
        }
    }
}
