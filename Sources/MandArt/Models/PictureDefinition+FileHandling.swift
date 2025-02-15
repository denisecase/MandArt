import Foundation
import SwiftUI
import UniformTypeIdentifiers

extension PictureDefinition {
  @MainActor
  func saveMandArtImageInputs(to url: URL? = nil, appState: AppState) {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

    // Save only if a file was previously opened, otherwise require Save As
    let saveURL = url ?? appState.currentFileURL

    guard let saveURL = saveURL else {
      print("WARNING: No previously opened file. Please use 'Save As' first.")
      return
    }

    do {
      let data = try encoder.encode(self)
      try data.write(to: saveURL)
      print("SUCCESS: MandArt saved to: \(saveURL.path)")

      // Update the file reference so future "Save" calls use this file
      appState.updateCurrentFile(url: saveURL)
    } catch {
      print("ERROR saving MandArt: \(error.localizedDescription)")
    }
  }

  @MainActor
  func saveMandArtImageInputsAs(appState: AppState) {
    let panel = NSSavePanel()
    panel.allowedContentTypes = [UTType.json]
    panel.nameFieldStringValue = "NewArtwork.mandart"

    if panel.runModal() == .OK, let url = panel.url {
      saveMandArtImageInputs(to: url, appState: appState)

      appState.updateCurrentFile(url: url)
    }
  }

  /// Returns the last opened file URL (used for overwriting)
  private var lastOpenedFileURL: URL? {
    // Store and retrieve the last opened file path
    // This should be managed at the app level (set it when opening a file)
    return nil // Needs to be set when loading a file
  }

  /// Loads a MandArt file from disk and returns a `PictureDefinition` instance.
  static func loadMandArtFile(from url: URL) -> PictureDefinition? {
    do {
      let data = try Data(contentsOf: url)
      guard !data.isEmpty else {
        print("Error: File at \(url.path) is empty.")
        return nil
      }
      let decoder = JSONDecoder()
      let pictureDefinition = try decoder.decode(PictureDefinition.self, from: data)
      print("Successfully loaded MandArt file from \(url.path)")
      return pictureDefinition
    } catch {
      print("Error loading MandArt file: \(error.localizedDescription)")
      return nil
    }
  }

  /// Saves the current MandArt image as a PNG file.
  func saveMandArtImageAsPNG(image: NSImage) {
    let panel = NSSavePanel()
    panel.allowedContentTypes = [UTType.png]
    panel.nameFieldStringValue = "NewArtwork.png"

    if panel.runModal() == .OK, let url = panel.url {
      guard let data = image.pngData() else {
        print("Error: Could not convert image to PNG data")
        return
      }

      do {
        try data.write(to: url)
        print("Image saved successfully to \(url.path)")
      } catch {
        print("Error saving image: \(error.localizedDescription)")
      }
    }
  }
}

import AppKit

extension NSImage {
  func pngData() -> Data? {
    guard let tiffData = tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData)
    else {
      return nil
    }
    return bitmap.representation(using: .png, properties: [:])
  }
}
