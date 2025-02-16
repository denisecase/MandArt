import SwiftUI
import UniformTypeIdentifiers

extension MandArtApp {
  // MARK: Open from list......................

  func openMandArtFromList(appState: AppState) {
    guard let url = Bundle.main.url(forResource: "mandart_discoveries", withExtension: "json") else {
      print("ERROR: JSON file LIST not found in bundle")
      return
    }
    print("SUCCESS: JSON file LIST found at \(url.path)")

    var discoveries = loadMandArtDiscoveries()

    guard !discoveries.isEmpty else {
      print("No MandArt discoveries available.")
      return
    }

    // Sort discoveries alphabetically by name
    discoveries.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }

    // Deduplicate discoveries based on name
    var uniqueDiscoveries: [String: MandArtDiscovery] = [:]
    for discovery in discoveries {
      if uniqueDiscoveries[discovery.name] == nil {
        uniqueDiscoveries[discovery.name] = discovery // Keep the first occurrence
      }
    }

    let deduplicatedDiscoveries = Array(uniqueDiscoveries.values)

    confirmReplaceMandArt(fromSource: "a list of discovered options", appState: appState) {
      DispatchQueue.main.async {
        let selectionView = MandArtSelectionView(discoveries: deduplicatedDiscoveries) { selectedMandArt in
          guard let selectedURL = URL(string: selectedMandArt.mandart_url), !selectedMandArt.mandart_url.isEmpty else {
            print("ERROR: Invalid URL for MandArt: \(selectedMandArt.name)")
            return
          }

          print("LIST: User selected MandArt: \(selectedMandArt.name)")
          print("LIST: Loading from URL: \(selectedMandArt.mandart_url)")

          Task {
            do {
              let newPicdef = try await loadMandArt(from: selectedURL)
              await MainActor.run {
                appState.picdef = newPicdef
                appState.activeFileName = url.lastPathComponent // Store file name
                updateWindowTitle(appState: appState) // Update window title
              }
            } catch {
              await MainActor.run {
                let errorAlert = NSAlert()
                errorAlert.messageText = "Error Loading MandArt"
                errorAlert
                  .informativeText =
                  "Failed to load MandArt from:\n\(selectedMandArt.mandart_url)\n\nPlease check the URL and try again."
                errorAlert.alertStyle = .critical
                errorAlert.addButton(withTitle: "OK")
                errorAlert.runModal()
              }
            }
          }
        }

        // Present the selection view as a modal window
        let hostingController = NSHostingController(rootView: selectionView)
        let window = NSWindow(contentViewController: hostingController)
        window.setContentSize(NSSize(width: 600, height: 400))
        window.styleMask = [.titled, .closable, .resizable]
        window.title = "Select a MandArt Discovery"
        window.makeKeyAndOrderFront(nil)
      }
    }
  }

  // MARK: Open from URL ...............................

  func openMandArtFromURL(appState: AppState, urlString: String? = nil) {
    var finalURLString: String = urlString ??
      "https://raw.githubusercontent.com/denisecase/MandArt-Discoveries/refs/heads/main/brucehjohnson/MAPPED/Dd01/Frame54.mandart"

    let alert = NSAlert()
    alert.messageText = "Open MandArt from URL"
    alert.informativeText = "Enter the URL of the .mandart file:"
    alert.alertStyle = .informational
    alert.addButton(withTitle: "Open")
    alert.addButton(withTitle: "Cancel")

    // Create the input field and set the default value
    let inputField = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 84))
    inputField.stringValue = finalURLString
    inputField.isEditable = true
    inputField.isSelectable = true
    inputField.allowsEditingTextAttributes = false
    inputField.usesSingleLineMode = true
    inputField.focusRingType = .default // Ensures focus for ⌘V paste

    alert.accessoryView = inputField

    // Bring the input field into focus (for immediate pasting support)
    DispatchQueue.main.async {
      inputField.window?.makeFirstResponder(inputField)
    }

    let response = alert.runModal()
    if response == .alertFirstButtonReturn {
      finalURLString = inputField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
    } else {
      return // User canceled
    }

    // Validate the final URL string
    guard let url = URL(string: finalURLString), url.scheme != nil else {
      print("Invalid URL: \(finalURLString)")
      // Show alert and exit the function
      DispatchQueue.main.async {
        self.showInvalidJSONAlert(stringURL: finalURLString)
      }
      return
    }

    Task {
      do {
        let newPicdef = try await loadMandArt(from: url)
        await MainActor.run {
          appState.picdef = newPicdef
          appState.activeFileName = url.lastPathComponent // Store file name
          updateWindowTitle(appState: appState) // Update window title
        }
      } catch {
        print("Error loading MandArt from URL: \(error)")

        // Ensure alert runs on the main thread
        DispatchQueue.main.async {
          self.showInvalidJSONAlert(stringURL: finalURLString)
        }
      }
    }
  }

  // MARK: - Open MandArt from Local File

  func openMandArtFromFile(appState: AppState) {
    let openPanel = NSOpenPanel()
    openPanel.allowedContentTypes = [UTType(filenameExtension: "mandart")!]
    openPanel.allowsMultipleSelection = false
    openPanel.canChooseDirectories = false
    openPanel.canCreateDirectories = false
    openPanel.title = "Select a MandArt File"

    if openPanel.runModal() == .OK, let url = openPanel.url {
      Task {
        do {
          let newPicdef = try await loadMandArt(from: url)
          await MainActor.run {
            appState.picdef = newPicdef
            appState.activeFileName = url.lastPathComponent // Store file name
            updateWindowTitle(appState: appState) // Update window title
          }
        } catch {
          print("Error loading MandArt from file: \(error)")
        }
      }
    }
  }

  // MARK: - Load MandArt from URL or File

  func loadMandArt(from url: URL) async throws -> PictureDefinition {
    let (data, _) = try await URLSession.shared.data(from: url)
    let decoder = JSONDecoder()
    let picdef = try decoder.decode(PictureDefinition.self, from: data)
    return picdef
  }
}
