import SwiftData
import SwiftUI

struct PanelUI: View {
  @EnvironmentObject var appState: AppState
  @Environment(\.modelContext) private var modelContext
  @ObservedObject var popupManager: PopupManager
  @State private var selectedTab = 0

  var body: some View {
    VStack { // Explicit alignment & spacing
      Text("MandArt Inputs")
        .font(.title)
        .padding(.top)

      Text("Use Help in menu to see documentation on using the app.")
        .font(.system(size: 14))
        .padding(.top, 1)

      Divider()

      TabbedView(
        popupManager: popupManager
      ).environmentObject(appState)

      Spacer()
    }
    .frame(maxWidth: .infinity, alignment: .topLeading) // Ensure correct positioning
    .padding()
    .onAppear {
      print("panelUI: onAppear")
    }
  }

  /// Calls AppState function to update the current picture definition
  private func updatePicdef(_ newPicdef: PictureDefinition) {
    appState.updatePicdef(newPicdef)
  }

  /// Calls AppState function to add a new picture definition
  private func addNewPictureDefinition() {
    appState.addNewPictureDefinition()
  }
}
