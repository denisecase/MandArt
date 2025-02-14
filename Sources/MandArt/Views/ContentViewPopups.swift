import SwiftUI
import SwiftData

/// `ContentViewPopups` is a SwiftUI `View` responsible for displaying specific popups based on the state of the `PopupManager`.
struct ContentViewPopups: View {
    @Binding var picdef: PictureDefinition
    @ObservedObject var popupManager: PopupManager
    @Binding var requiresFullCalc: Bool
    
    /// Initializes the `ContentViewPopups` with necessary dependencies.
    /// - Parameters:
    ///   - picdef: The current `PictureDefinition` being modified.
    ///   - popupManager: An object managing the popups' display state.
    ///   - requiresFullCalc: A binding to control the calculation state.
    init(
        picdef: Binding<PictureDefinition>,
        popupManager: PopupManager,
        requiresFullCalc: Binding<Bool>
    ) {
        _picdef = picdef
        self.popupManager = popupManager
        _requiresFullCalc = requiresFullCalc
    }
    
    /// The main body of the `ContentViewPopups`.
    var body: some View {
        ScrollView {
            if picdef.hues.isEmpty == false {
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
            return AnyView(PopupPrintableColors(picdef: $picdef, popupManager: popupManager, hues: picdef.hues))
        case .None:
            return AnyView(EmptyView())
        }
    }
    
    /// The color cube popup (if any)
    private func contentForCube() -> some View {
        switch popupManager.showingCube {
        case .APRed, .APGreen, .APBlue, .AllBlue, .AllRed, .AllGreen:
            return AnyView(PopupColorCube(picdef: $picdef, popupManager: popupManager, hues: picdef.hues))
        case .None:
            return AnyView(EmptyView())
        }
    }
}
