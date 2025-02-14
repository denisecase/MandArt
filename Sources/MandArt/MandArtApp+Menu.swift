// MandArtApp+Menu.swift
import SwiftUI

extension MandArtApp {
    
    func appMenuCommands(appState: AppState) -> some Commands {
        return Group {
            
            // Remove native New Window/New Document commands.
            CommandGroup(replacing: CommandGroupPlacement.newItem) { }
            
            // Remove native window arrangement options
            CommandGroup(replacing: CommandGroupPlacement.windowArrangement) { }

            
            
            // Insert custom Open commands after the native Open items.
            CommandGroup(before: CommandGroupPlacement.saveItem) {
                
                Button("Reset MandArt") {
                    print("Reset MandArt")
                }
                .keyboardShortcut("r", modifiers: [.command])
                
                Button("Open MandArt from URL…") {
                    // Placeholder: Insert URL-based loading logic here.
                    print("Open MandArt from URL…")
                }
                .keyboardShortcut("o", modifiers: [.command, .shift])
                
                Button("Open MandArt from Machine…") {
                    // Placeholder: Insert local file open logic here.
                    print("Open MandArt from Machine…")
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
}
