import SwiftUI
import SwiftData

@available(macOS 12.0, *)
struct PanelUI: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var picdef: PictureDefinition
    @ObservedObject var popupManager: PopupManager
    @Binding var requiresFullCalc: Bool
    @Binding var showGradient: Bool
    @State private var selectedTab = 0
    
    var body: some View {
        VStack {
            Text("MandArt Inputs")
                .font(.title)
                .padding(.top)
            
            Text("Use Help in menu to see documentation on using the app.")
                .font(.system(size: 14))
                .padding(.top, 1)
            
            
            TabbedView(
                picdef: $picdef,
                popupManager: popupManager,
                requiresFullCalc: $requiresFullCalc,
                showGradient: $showGradient
            )
            
            Spacer()
        }
    }
    
    /// Updates an existing `PictureDefinition`
    private func updatePicdef(_ newPicdef: PictureDefinition) {
        picdef.hues = newPicdef.hues
        picdef.leftNumber = newPicdef.leftNumber
        picdef.mandColor = newPicdef.mandColor
        picdef.scale = newPicdef.scale
        picdef.theta = newPicdef.theta
        picdef.iterationsMax = newPicdef.iterationsMax
    }
    
    /// Adds a new `PictureDefinition` instance if needed
    private func addNewPictureDefinition() {
        let newPicdef = PictureDefinition()
        modelContext.insert(newPicdef)
    }
}
