import SwiftUI
import SwiftData

@available(macOS 12.0, *)
struct PanelUI: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var popupManager: PopupManager
    @State private var selectedTab = 0
    
    var body: some View {
        VStack() { // Explicit alignment & spacing
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

    }
    
    /// Updates an existing `PictureDefinition`
    private func updatePicdef(_ newPicdef: PictureDefinition) {
        appState.picdef.hues = newPicdef.hues
        appState.picdef.leftNumber = newPicdef.leftNumber
        appState.picdef.mandColor = newPicdef.mandColor
        appState.picdef.scale = newPicdef.scale
        appState.picdef.theta = newPicdef.theta
        appState.picdef.iterationsMax = newPicdef.iterationsMax
    }
    
    /// Adds a new `PictureDefinition` instance if needed
    private func addNewPictureDefinition() {
        let newPicdef = PictureDefinition()
        modelContext.insert(newPicdef)
    }
}
