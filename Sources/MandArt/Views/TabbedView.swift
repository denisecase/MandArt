import SwiftUI
import UniformTypeIdentifiers

struct TabbedView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var popupManager = PopupManager()
    @State private var selectedTab = 0
    
    var body: some View {
        VStack {
            Picker("Options", selection: $selectedTab) {
                Text("1. Find").tag(0)
                Text("2. Color").tag(1)
                Text("3. Tune").tag(2)
                Text("4. Save").tag(3)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Use the computed view property for your tab content.
            viewForSelectedTab
                .padding(.top, 8)
        }
        .padding()
    }
    
    // This computed property uses @ViewBuilder to infer the correct type.
    @ViewBuilder
    private var viewForSelectedTab: some View {
        switch selectedTab {
        case 0:
            TabFind().environmentObject(appState)
        case 1:
            TabColor(popupManager: popupManager).environmentObject(appState)
        case 2:
            TabTune().environmentObject(appState)
        case 3:
            TabSave().environmentObject(appState)
        default:
            Text("Invalid selection")
        }
    }
}
