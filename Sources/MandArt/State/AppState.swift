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
  @Published var activeFileName: String?

  // MARK: - UI State Flags

  @Published var renderedImage: NSImage?
  @Published var requiresFullCalc: Bool = true
  @Published var showGradient: Bool = true
  @Published var showResetAlert: Bool = false
  @Published var showReplaceAlert: Bool = false

  // MARK: - Pending Actions

  @Published var pendingReplacement: (() -> Void)?

  // MARK: - Initializer

  init() {
    print("Initializing app state....")
    var tempPicdef = PictureDefinition()

    do {
      let result = try PersistenceManager.initializeSwiftData()
      modelContainer = result.container

      let fetchDescriptor = FetchDescriptor<PictureDefinition>()
      let existingPicdefs = try result.container.mainContext.fetch(fetchDescriptor)

      if existingPicdefs.isEmpty {
        let defaultPicdef = PictureDefinition()
        result.container.mainContext.insert(defaultPicdef)
        try result.container.mainContext.save()
        tempPicdef = defaultPicdef
      } else {
        picdef = existingPicdefs.first!

        if tempPicdef.hues.isEmpty {
          tempPicdef.hues = PictureDefinition.defaultHues
          try result.container.mainContext.save()
        }
      }
      tempPicdef.context = result.container.mainContext
    } catch {
      print("Failed to initialize SwiftData: \(error.localizedDescription). Using default.")
      modelContainer = nil
    }
    picdef = tempPicdef
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
