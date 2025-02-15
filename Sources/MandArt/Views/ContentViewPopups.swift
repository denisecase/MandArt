import SwiftData
import SwiftUI

/// `ContentViewPopups` is a SwiftUI `View` responsible for displaying specific popups based on the state of the
/// `PopupManager`.
struct ContentViewPopups: View {
  @EnvironmentObject var appState: AppState
  @ObservedObject var popupManager: PopupManager

  init(
    popupManager: PopupManager
  ) {
    self.popupManager = popupManager
  }

  /// The main body of the `ContentViewPopups`.
  var body: some View {
    ScrollView {
      if appState.picdef.hues.isEmpty == false {
        contentForPrintables()
        contentForCube()
      } else {
        Text("No Picture Definition Available")
          .foregroundColor(.gray)
      }
    }
    .edgesIgnoringSafeArea(.top) // Cover entire window
  }

  /// The printables popup (if any)
  private func contentForPrintables() -> some View {
    switch popupManager.showingPrintables {
    case .RGB, .RBG, .GBR, .GRB, .BGR, .BRG:
      return AnyView(PopupPrintableColors(popupManager: popupManager, hues: appState.picdef.hues))
    case .None:
      return AnyView(EmptyView())
    }
  }

  /// The color cube popup (if any)
  private func contentForCube() -> some View {
    switch popupManager.showingCube {
    case .APRed, .APGreen, .APBlue, .AllBlue, .AllRed, .AllGreen:
      return AnyView(PopupColorCube(popupManager: popupManager, hues: appState.picdef.hues))
    case .None:
      return AnyView(EmptyView())
    }
  }
}
