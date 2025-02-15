import Foundation
import SwiftUI

extension AppState {
  /// Load Last Opened File (Manual Menu Option)
  func loadLastOpenedMandArt() {
    if let lastOpenedPath = UserDefaults.standard.string(forKey: "lastOpenedFilePath") {
      let url = URL(fileURLWithPath: lastOpenedPath)

      if let data = try? Data(contentsOf: url),
         let loadedPicdef = try? JSONDecoder().decode(PictureDefinition.self, from: data) {
        print("Loaded last opened MandArt from: \(url.path)")
        picdef = loadedPicdef
        currentFileURL = url
        return
      }
    }
    print("No saved MandArt found. Using default.")
    picdef = PictureDefinition()
    currentFileURL = nil
  }

  /// Updates the current file path and saves it persistently.
  func updateCurrentFile(url: URL) {
    currentFileURL = url
    UserDefaults.standard.set(url.path, forKey: "lastOpenedFilePath")
    print("Updated current file to: \(url.path)")
  }
}
