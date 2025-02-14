import Foundation
import SwiftUI
import UniformTypeIdentifiers

extension PictureDefinition {
    
    /// Saves the MandArt image inputs as a JSON file in the Documents directory.
    func saveMandArtImageInputs() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        do {
            let data = try encoder.encode(self)
            let saveURL = getSaveURL()
            try data.write(to: saveURL)
            print("Image inputs saved successfully to \(saveURL.path)")
        } catch {
            print("Error saving MandArt image inputs: \(error.localizedDescription)")
        }
    }

    /// Returns the URL for saving the data file.
    private func getSaveURL() -> URL {
        let fileName = "MandArt_" + UUID().uuidString + ".mandart"
        return FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
    }

    /// Loads a MandArt file from disk and returns a `PictureDefinition` instance.
    static func loadMandArtFile(from url: URL) -> PictureDefinition? {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let pictureDefinition = try decoder.decode(PictureDefinition.self, from: data)
            print("Successfully loaded MandArt file from \(url.path)")
            return pictureDefinition
        } catch {
            print("Error loading MandArt file: \(error.localizedDescription)")
            return nil
        }
    }

    /// Saves the current MandArt image (as .png) with metadata.
    func saveMandArtImage(image: NSImage) {
        guard let data = image.pngData() else {
            print("Error: Could not convert image to PNG data")
            return
        }
        
        let saveURL = getSaveURL().deletingPathExtension().appendingPathExtension("png")
        
        do {
            try data.write(to: saveURL)
            print("Image saved successfully to \(saveURL.path)")
        } catch {
            print("Error saving image: \(error.localizedDescription)")
        }
    }
}

import AppKit

extension NSImage {
    func pngData() -> Data? {
        guard let tiffData = self.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData) else {
            return nil
        }
        return bitmap.representation(using: .png, properties: [:])
    }
}
