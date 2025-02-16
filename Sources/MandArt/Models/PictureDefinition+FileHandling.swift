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
    let savePanel = NSSavePanel()
    savePanel.allowedContentTypes = [UTType(filenameExtension: "mandart")!]

    // Use current filename if available; otherwise, default to "Untitled.mandart"
    let defaultFileName = appState.activeFileName ?? "Untitled.mandart"
    savePanel.nameFieldStringValue = defaultFileName
    savePanel.title = "Save MandArt As"
    savePanel.canCreateDirectories = true
    savePanel.showsTagField = false
    savePanel.isExtensionHidden = false

    if savePanel.runModal() == .OK, let url = savePanel.url {
      do {
        let jsonData = try JSONEncoder().encode(self)

        // Prevent overwriting without warning
        if FileManager.default.fileExists(atPath: url.path) {
          let alert = NSAlert()
          alert.messageText = "File Already Exists"
          alert.informativeText = "A file named \"\(url.lastPathComponent)\" already exists. Do you want to replace it?"
          alert.alertStyle = .warning
          alert.addButton(withTitle: "Replace")
          alert.addButton(withTitle: "Cancel")

          let response = alert.runModal()
          if response != .alertFirstButtonReturn { return } // Cancel overwrite
        }

        try jsonData.write(to: url)
        print("File saved successfully: \(url.path)")

        // Update the active file name and window title
        DispatchQueue.main.async {
          appState.activeFileName = url.lastPathComponent
          self.updateWindowTitle(appState: appState)
        }
      } catch {
        print("Error saving MandArt file: \(error)")
      }
    }
  }

  private func updateWindowTitle(appState: AppState) {
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
  @MainActor
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

  // MARK: ========================== OLD

  // Save the image inputs to a file.
  func saveMandArtImageInputs() {
    var data: Data
    do {
      let encoder = JSONEncoder()
      encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
      data = try encoder.encode(self)
    } catch {
      print("ERROR saving MandArt image inputs. ")
      return
    }
    if data.isEmpty {
      print("ERROR saving - data is empty. ")
      return
    }

    // trigger state change to force a current image
    imageHeight += 1
    imageHeight -= 1

    let savePanel = NSSavePanel()
    savePanel.title = "Choose directory and name for image inputs file"
    // TODO: DMC
    // savePanel.nameFieldStringValue = appState.activeFileName ?? "Untitled"
    savePanel.nameFieldStringValue = "Untitled"
    savePanel.canCreateDirectories = true
    savePanel.allowedContentTypes = [UTType.mandartDocType]

    savePanel.begin { result in
      if result == .OK {
        do {
          try data.write(to: savePanel.url!)
        } catch {
          print("Error saving file: \(error.localizedDescription)")
        }
        print("Image inputs saved successfully to \(savePanel.url!)")

        // Update the window title with the saved file name (without its extension)
        if let fileName = savePanel.url?.lastPathComponent {
          let justName = fileName.replacingOccurrences(of: ".mandart", with: "") // TODO: DMC
          NSApp.mainWindow?.title = justName
        }
      } else {
        print("Error saving image inputs")
      }
    }
  }

  func saveMandArtDataFile() {
    // first, save the data file and wait for it to complete
    DispatchQueue.main.async {
      // Trigger a "File > Save" menu event to update the app's UI.
      NSApp.sendAction(#selector(NSDocument.save(_:)), to: nil, from: self)
    }
  }

  func initSavePanel(fn: String) -> NSSavePanel {
    let savePanel = NSSavePanel()
    savePanel.title = "Choose Directory for MandArt image"
    savePanel.nameFieldStringValue = fn
    savePanel.canCreateDirectories = true
    return savePanel
  }

  // Saving PNG with Description comment

  func getCurrentWindowTitle() -> String {
    guard let mainWindow = NSApp.mainWindow else {
      return "MyArt"
    }
    return mainWindow.title
  }

  func getDefaultImageFileName() -> String {
    let winTitle = getCurrentWindowTitle()
    var justname = winTitle.replacingOccurrences(of: ".mandart3", with: "")
    if justname.isEmpty {
      justname = "MyArt"
    }
    let imageFileName = justname + ".png"
    return imageFileName
  }

  func getImageComment() -> String {
    var comment =
      "-----------\n" +
      "FIND TAB\n" +
      "-----------\n" +
      "width is \(String(imageWidth)) \n" +
      "height is \(String(imageHeight)) \n" +
      "horizontal_xCenter is \(String(xCenter)) \n" +
      "vertical_yCenter is \(String(yCenter)) \n" +
      "magnification_scale is \(String(scale)) \n" +
      "iterationsMax_tries is \(String(iterationsMax)) \n" +
      "rotation_theta is \(String(theta)) \n" +
      "smoothing_rSqLimit is \(String(rSqLimit)) \n" +
      "-----------\n" +
      "TUNE TAB\n" +
      "-----------\n" +
      "spacingColorFar_fromMand is \(String(spacingColorFar)) \n" +
      "spacingColorNear_toMand is \(String(spacingColorNear)) \n" +
      "min_tries_dFIterMin is \(String(dFIterMin)) \n" +
      "nBlocks is \(String(nBlocks)) \n" +
      "hold_fraction_yY is \(String(yY)) \n" +
      "-----------\n" +
      "COLOR TAB\n" +
      "-----------\n" +
      "leftNumber is \(String(leftNumber)) \n"

    for hue in hues {
      comment += "\(hue.num): R=\(hue.r), G=\(hue.g), B=\(hue.b)\n"
    }
    return comment
  }

  func beforeSaveImage() {
    var data: Data
    do {
      data = try JSONEncoder().encode(self)
    } catch {
      print("Error encoding picdef.")
      print("Closing all windows and exiting with error code 98.")
      NSApplication.shared.windows.forEach { $0.close() }
      NSApplication.shared.terminate(nil)
      exit(98)
    }
    if data == Data() {
      print("Error encoding picdef.")
      print("Closing all windows and exiting with error code 99.")
      NSApplication.shared.windows.forEach { $0.close() }
      NSApplication.shared.terminate(nil)
      exit(99)
    }
    // trigger state change to force a current image
    imageHeight += 1
    imageHeight -= 1
  }

  // requires Cocoa
  // requires ImageIO
  func setPNGDescription(imageURL: URL, description: String) throws {
    // Get the image data
    guard let imageData = try? Data(contentsOf: imageURL) else {
      throw NSError(
        domain: "com.bhj.mandart3",
        code: 0,
        userInfo: [NSLocalizedDescriptionKey: "Failed to read image data"]
      )
    }

    // Create a CGImageSource from the image data
    guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil) else {
      throw NSError(
        domain: "com.bhj.mandart3",
        code: 0,
        userInfo: [NSLocalizedDescriptionKey: "Failed to create image source"]
      )
    }

    // Create a CGImageDestination to write the image with metadata
    guard let destination = CGImageDestinationCreateWithURL(imageURL as CFURL, kUTTypePNG, 1, nil) else {
      throw NSError(
        domain: "com.bhj.mandart3",
        code: 0,
        userInfo: [NSLocalizedDescriptionKey: "Failed to create image destination"]
      )
    }

    // Get the image properties dictionary
    guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any] else {
      throw NSError(
        domain: "com.bhj.mandart3",
        code: 0,
        userInfo: [NSLocalizedDescriptionKey: "Failed to get image properties"]
      )
    }

    // Create a mutable copy of the properties dictionary
    var mutableProperties = properties as [CFString: Any]

    // Add the PNG dictionary with the description attribute
    var pngProperties = [CFString: Any]()
    pngProperties[kCGImagePropertyPNGDescription] = description
    mutableProperties[kCGImagePropertyPNGDictionary] = pngProperties

    // Add the image to the destination with metadata
    CGImageDestinationAddImageFromSource(destination, imageSource, 0, mutableProperties as CFDictionary)

    // Finalize the destination to write the image with metadata to disk
    guard CGImageDestinationFinalize(destination) else {
      throw NSError(
        domain: "com.bhj.mandart3",
        code: 0,
        userInfo: [NSLocalizedDescriptionKey: "Failed to write image with metadata to disk"]
      )
    }
  }

  func saveMandArtImage() {
    beforeSaveImage()
    guard let cgImage = contextImageGlobal else {
      print("Error: No context image available.")
      return
    }
    let imageFileName: String = getDefaultImageFileName()
    let comment: String = getImageComment()
    let savePanel: NSSavePanel = initSavePanel(fn: imageFileName)

    // Set the description attribute in the PNG metadata
    let pngMetadata: [String: Any] = [
      kCGImagePropertyPNGDescription as String: comment,
    ]

    savePanel.begin { result in
      if result == .OK, let url = savePanel.url {
        let imageData = cgImage.pngData()!
        let ciImage = CIImage(data: imageData, options: [.properties: pngMetadata])
        let context = CIContext(options: nil)

        guard let pngData = context.pngRepresentation(of: ciImage!, format: .RGBA8, colorSpace: ciImage!.colorSpace!)
        else {
          print("Error: Failed to generate PNG data.")
          return
        }

        do {
          try pngData.write(to: url, options: .atomic)
          print("Saved image to: \(url)")
          print("Description: \(comment)")
          // Needed to actually write the description
          let imageURL = url
          let description = comment
          try self.setPNGDescription(imageURL: imageURL, description: description)
        } catch {
          print("Error saving image: \(error)")
        }
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
