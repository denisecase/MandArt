import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct TabSave: View {
  @EnvironmentObject var appState: AppState
  @ObservedObject var popupManager = PopupManager()

  var body: some View {
    ScrollView {
      VStack {
        Section(
          header:
          Text("Save Your Art")
            .font(.headline)
            .fontWeight(.medium)
            .padding(.vertical)
        ) {
          Button("Save Picture Inputs (as data file)") {
            appState.picdef.saveMandArtImageInputs()
          }
          .help("Save MandArt picture inputs as .mandart.")

          Button("Export as PNG") {
            appState.picdef.saveMandArtImage()
          }
          .help("Save MandArt picture as .png.")
        } // end section
      } // VStack
    } // ScrollView
    .onAppear {
      appState.updateRequiresFullCalc(false)
      appState.updateShowGradient(false)
    }
    .onDisappear {
      if appState.requiresFullCalc {
        appState.updateRequiresFullCalc(false)
      }
    }
  }
}
