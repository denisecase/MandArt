import AppKit
import SwiftUI

extension MandArtApp {
  func updateWindowTitle(appState: AppState) {
    DispatchQueue.main.async {
      if let window = NSApplication.shared.windows.first {
        if let fileName = appState.activeFileName {
          window.title = "MandArt - \(fileName)"
        } else {
          window.title = "MandArt"
        }
      }
    }
  }
}
