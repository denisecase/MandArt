// MandArtApp+Menu.swift
import SwiftUI
import UniformTypeIdentifiers

extension MandArtApp {
  func appMenuCommands(appState: AppState) -> some Commands {
    return Group {
      // Remove native New Window/New Document commands.
      CommandGroup(replacing: CommandGroupPlacement.newItem) {}

      // Remove native window arrangement options
      CommandGroup(replacing: CommandGroupPlacement.windowArrangement) {}

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
          confirmResetMandArt(appState: appState)
        }
        .keyboardShortcut("r", modifiers: [.command])

        Button("Open MandArt from List…") {
          openMandArtFromList(appState: appState)
        }
        .keyboardShortcut("o", modifiers: [.command, .shift])

        Button("Open MandArt from URL…") {
          confirmReplaceMandArt(fromSource: "a URL", appState: appState) {
            openMandArtFromURL(appState: appState)
          }
        }
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
          if appState.activeFileName == nil || appState.activeFileName!.isEmpty {
            appState.picdef.saveMandArtImageInputsAs(appState: appState)
          } else {
            appState.picdef.saveMandArtImageInputs(appState: appState)
          }
        }

        .keyboardShortcut("s", modifiers: [.command])

        Button("Save MandArt As…") {
          appState.picdef.saveMandArtImageInputsAs(appState: appState)
        }
        .keyboardShortcut("s", modifiers: [.command, .shift])

        Button("Export as PNG") {
          if let image = appState.generateNSImage() {
            appState.picdef.saveMandArtImageAsPNG(image: image)
          }
        }
        .keyboardShortcut("e", modifiers: [.command])
      } // command group

      // Remove Edit/Pasteboard menu
      CommandGroup(replacing: CommandGroupPlacement.pasteboard) {}

      // Help Menu: Replace default help with links
      CommandGroup(replacing: CommandGroupPlacement.help) {
        let displayText = "MandArt Help"
        let url = URL(string: "https://denisecase.github.io/MandArt-Docs/documentation/mandart/")!
        Link(displayText, destination: url)

        let displayText2 = "MandArt Discoveries"
        let url2 = URL(string: "https://denisecase.github.io/MandArt-Discoveries/")!
        Link(displayText2, destination: url2)
      }
    } // Group
  } // app Menu commands
}
