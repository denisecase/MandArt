import SwiftUI
import UniformTypeIdentifiers

@available(macOS 12.0, *)
struct TabFind: View {
  @EnvironmentObject var appState: AppState

  var body: some View {
    ScrollView {
      VStack {
        TabFindDefaultButtons().environmentObject(appState)
        TabFindImageSize().environmentObject(appState)
        TabFindImageCenter().environmentObject(appState)
        TabFindImagePower().environmentObject(appState)
        TabFindScale().environmentObject(appState)
        TabFindRotateAndSmoothing().environmentObject(appState)
        Spacer()
      } //  vstack
    } // scrollview
    .onAppear {
      appState.updateRequiresFullCalc(true)
      appState.updateShowGradient(false)
    }
    .onDisappear {
      if appState.requiresFullCalc {
        appState.updateRequiresFullCalc(false)
      }
    }
  }
}
