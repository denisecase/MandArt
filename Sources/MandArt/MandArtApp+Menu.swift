// MandArtApp+Menu.swift
import SwiftUI
import UniformTypeIdentifiers

extension MandArtApp {
    
    func appMenuCommands(appState: AppState) -> some Commands {
        return Group {
            
            // Remove native New Window/New Document commands.
            CommandGroup(replacing: CommandGroupPlacement.newItem) { }
            
            // Remove native window arrangement options
            CommandGroup(replacing: CommandGroupPlacement.windowArrangement) { }

            // Remove native File / Close window option
            CommandGroup(after: .appInfo) {
                Button("Close Window") {
                    print("Close window disabled.") // No actual close action
                }
                .keyboardShortcut("w", modifiers: .command)
                .disabled(true) // Prevents the user from closing the last window
            }

            
            // Insert custom Open commands after the native Open items.
            CommandGroup(before: CommandGroupPlacement.saveItem) {
                
                Button("Reset MandArt") {
                    appState.showResetAlert = true
                }
                .keyboardShortcut("r", modifiers: [.command])
                
                Button("Open MandArt from List…") {
                        openMandArtFromList(appState: appState)
                        }
                .keyboardShortcut("o", modifiers: [.command, .shift])
                
                Button("Open MandArt from URL…") {
                    confirmReplaceMandArt(fromSource: "a URL", appState: appState) {
                        openMandArtFromURL(appState: appState)
                    }                }
                .keyboardShortcut("o", modifiers: [.command, .shift])
                
                Button("Open MandArt from Machine…") {
                    confirmReplaceMandArt(fromSource: "a file", appState: appState) {
                        openMandArtFromFile(appState: appState)
                    }
                }
                .keyboardShortcut("o", modifiers: [.command])
            }
            
            // Insert custom Save/Export commands after the native Save items.
            CommandGroup(after: CommandGroupPlacement.saveItem) {
                Button("Save MandArt") {
                    appState.picdef.saveMandArtImageInputs()
                }
                .keyboardShortcut("s", modifiers: [.command])
                
                Button("Save MandArt As…") {
                    appState.picdef.saveMandArtImageInputsAs()
                }
                .keyboardShortcut("s", modifiers: [.command, .shift])
                
                Button("Export as PNG") {
                    if let image = appState.renderedImage {
                        appState.picdef.saveMandArtImageAsPNG(image: image)
                    } else {
                        print("No image to export.")
                    }
                }
                .keyboardShortcut("e", modifiers: [.command])
            }
            
            // Remove Edit/Pasteboard menu
            CommandGroup(replacing: CommandGroupPlacement.pasteboard) {}
            
            // Help Menu: Replace default help with links
            CommandGroup(replacing: CommandGroupPlacement.help) {
                let displayText: String = "MandArt Help"
                let url: URL = URL(string: "https://denisecase.github.io/MandArt-Docs/documentation/mandart/")!
                Link(displayText, destination: url)
                
                let displayText2: String = "MandArt Discoveries"
                let url2: URL = URL(string: "https://denisecase.github.io/MandArt-Discoveries/")!
                Link(displayText2, destination: url2)
            }
        }
    }
    
    // MARK: - Helper Functions for Open MandArt from URL
    
    private func confirmReplaceMandArt(fromSource source: String, appState: AppState, action: @escaping () -> Void) {
        let alert = NSAlert()
        alert.messageText = "Replace Current MandArt?"
        alert.informativeText = "Are you sure you want to replace the current MandArt with one from \(source)?"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Replace")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            action()  // Execute the replacement action
        }
    }
    
    private func openMandArtFromList(appState: AppState) {
        
        if let url = Bundle.main.url(forResource: "mandart_discoveries", withExtension: "json") {
            print("SUCCESS: JSON file found at \(url.path)")
        } else {
            print("ERROR: JSON file not found in bundle")
        }

        let discoveries = loadMandArtDiscoveries()
        
        guard !discoveries.isEmpty else {
            print("No MandArt discoveries available.")
            return
        }
        
        // Create an alert to display the list
        let alert = NSAlert()
        alert.messageText = "Select a MandArt Discovery"
        alert.informativeText = "Choose a file from the list to open:"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Open")
        alert.addButton(withTitle: "Cancel")
        
        // Create a dropdown (pop-up) button
        let dropdown = NSPopUpButton(frame: NSRect(x: 0, y: 0, width: 300, height: 30))
        let names = discoveries.map { $0.name }
        dropdown.addItems(withTitles: names)
        
        alert.accessoryView = dropdown
        
        // Run the modal and get user selection
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            let selectedIndex = dropdown.indexOfSelectedItem
            let selectedMandArt = discoveries[selectedIndex]
            confirmReplaceMandArt(fromSource: selectedMandArt.name, appState: appState) {
                openMandArtFromURL( appState: appState, urlString: selectedMandArt.url)
            }
        }
    }

    
    private func openMandArtFromURL(appState: AppState, urlString: String? = nil) {
        var finalURLString: String = urlString ?? ""
        
        // If no URL is provided, prompt the user for one
        if finalURLString.isEmpty {
            let alert = NSAlert()
            alert.messageText = "Open MandArt from URL"
            alert.informativeText = "Enter the URL of the .mandart file:"
            alert.alertStyle = .informational
            alert.addButton(withTitle: "Open")
            alert.addButton(withTitle: "Cancel")
            
            let inputField = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 72))
            alert.accessoryView = inputField
            
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                finalURLString = inputField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                return // User canceled
            }
        }
        
        // Validate the final URL string
        guard let url = URL(string: finalURLString), url.scheme != nil else {
            print("Invalid URL: \(finalURLString)")
            return
        }
        
        // Load the MandArt from the URL
        Task {
            do {
                let newPicdef = try await loadMandArt(from: url)
                await MainActor.run {
                    appState.picdef = newPicdef
                }
            } catch {
                print("Error loading MandArt from URL: \(error)")
            }
        }
    }

    

    // MARK: - Open MandArt from Local File
    private func openMandArtFromFile(appState: AppState) {
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
                    }
                } catch {
                    print("Error loading MandArt from file: \(error)")
                }
            }
        }
    }
    
    // MARK: - Load MandArt from URL or File
    private func loadMandArt(from url: URL) async throws -> PictureDefinition {
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        let picdef = try decoder.decode(PictureDefinition.self, from: data)
        return picdef
    }
}

