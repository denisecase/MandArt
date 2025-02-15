import AppKit // for rendered image
import SwiftData
import SwiftUI

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
    print("Initializing app state....")
    do {
      let result = try PersistenceManager.initializeSwiftData()
      modelContainer = result.container
      print("result: \(result)")

      let fetchDescriptor = FetchDescriptor<PictureDefinition>()
      let existingPicdefs = try result.container.mainContext.fetch(fetchDescriptor)
      print("existingPicdefs: \(existingPicdefs)")

      if existingPicdefs.isEmpty {
        print("Empty existing picdefs, creating a new one.")
        let defaultPicdef = PictureDefinition()
        result.container.mainContext.insert(defaultPicdef)
        picdef = defaultPicdef
        try result.container.mainContext.save()
      } else {
        print("Count of picdefs found: \(existingPicdefs.count)")
        picdef = existingPicdefs.first! // Load the first existing one

        // Check if hues are missing and load defaults if necessary
        if picdef.hues.isEmpty {
          print("Warning: Loaded picdef has no hues. Using default hues.")
          picdef.hues = PictureDefinition.defaultHues
          try result.container.mainContext.save()
        }

        print("loaded picdef: \(picdef)")
      }
      picdef.context = result.container.mainContext
      print("AppState setup complete.")
      print("Final picdef: \(picdef)")

    } catch {
      print("Failed to initialize SwiftData: \(error.localizedDescription). Using default.")
      modelContainer = nil
      picdef = PictureDefinition()
    }
  }

  // MARK: - Save Function

  func saveToSwiftData() {
    guard let context = modelContainer?.mainContext else { return }

    // Ensure picdef exists
    guard let picdef = picdef as? PictureDefinition else {
      print("Error: picdef is nil or incorrect type")
      return
    }

    // Convert huesData and mandColorData to JSON for debugging
    let huesJson = String(data: picdef.huesData, encoding: .utf8) ?? "Invalid Data"
    let mandColorJson = String(data: picdef.mandColorData, encoding: .utf8) ?? "Invalid Data"

    print("Saving hues JSON: \(huesJson)")
    print("Saving mandColor JSON: \(mandColorJson)")

    do {
      try context.save()
      print("Successfully saved changes to SwiftData")
    } catch {
      print("Error saving SwiftData: \(error)")
    }
  }
}
