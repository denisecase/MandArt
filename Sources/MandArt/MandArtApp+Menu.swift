import SwiftUI

extension MandArtApp {
    
    func appMenuCommands(appState: AppState) -> some Commands {
        return Group {
            
            CommandMenu("File") {
                Button("Save") {
                    appState.picdef.saveMandArtImageInputs()
                }
                .keyboardShortcut("s", modifiers: [.command])
                
                Button("Save As…") {
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
            
            CommandMenu("Welcome") {
                Button("Show Welcome Screen") {
                    let controller = WelcomeWindowController(appState: appState)
                    controller.showWindow(self)
                    controller.window?.makeKeyAndOrderFront(nil)
                }
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
