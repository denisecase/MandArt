import SwiftUI

extension MandArtApp {
  func appMenuCommands() -> some Commands {
    Group {
      // Disable "New Window" option
      // CommandGroup(replacing: .newItem) {}

      CommandMenu("Welcome") {
        Button("Show Welcome Screen") {
          let controller = WelcomeWindowController(appState: self.appState)
          controller.showWindow(self)
          controller.window?.makeKeyAndOrderFront(nil)
        }
      }

      // we don't need the Edit/pasteboard menu item (cut/copy/paste/delete)
      // so we'll replace it with nothing
      CommandGroup(replacing: CommandGroupPlacement.pasteboard) {}

      // Help has "Search" & "MandArt Help" by default
      // let's replace the MandArt help option with links
      // to our hosted documentation on GitHub Pages
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
