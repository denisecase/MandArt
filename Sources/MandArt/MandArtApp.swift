import AppKit
import SwiftData
import SwiftUI
import UniformTypeIdentifiers
import Foundation

@main
struct MandArtApp: App {
  @StateObject var appState = AppState()
  
  init(){
    // Run the script
   // ArtImage.makeGrids()
  }



  var body: some Scene {
    WindowGroup {
      ContentView().environmentObject(appState)
        .onAppear {
          print("Window Group Content View Appeared")
        }
    }
    .defaultSize(width: windowWidth, height: windowHeight)
    .commands {
      appMenuCommands(appState: appState)
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
