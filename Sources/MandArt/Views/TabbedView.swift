import SwiftUI
import UniformTypeIdentifiers

struct TabbedView: View {
    @Binding var picdef: PictureDefinition
    @ObservedObject var popupManager = PopupManager()
    @Binding var requiresFullCalc: Bool
    @Binding var showGradient: Bool
    @State private var selectedTab = 0
    
    init(
        picdef: Binding<PictureDefinition>,
        popupManager: PopupManager,
        requiresFullCalc: Binding<Bool>,
        showGradient: Binding<Bool>
    ) {
        _picdef = picdef
        self.popupManager = popupManager
        _requiresFullCalc = requiresFullCalc
        _showGradient = showGradient
    }
    
    var body: some View {
        VStack {
            // Instead of `TabView`, use a Picker for tab switching
            Picker("Options", selection: $selectedTab) {
                Text("1. Find").tag(0)
                Text("2. Color").tag(1)
                Text("3. Tune").tag(2)
                Text("4. Save").tag(3)
            }
            .pickerStyle(SegmentedPickerStyle()) // look like tabs
            .padding(.horizontal)
            
            // Show different views based on selectedTab
            Group {
                switch selectedTab {
                case 0:
                    TabFind(picdef: $picdef, requiresFullCalc: $requiresFullCalc, showGradient: $showGradient)
                case 1:
                    TabColor(picdef: $picdef, popupManager: popupManager, requiresFullCalc: $requiresFullCalc, showGradient: $showGradient)
                case 2:
                    TabTune(picdef: $picdef, requiresFullCalc: $requiresFullCalc, showGradient: $showGradient)
                case 3:
                    TabSave(picdef: $picdef, popupManager: popupManager, requiresFullCalc: $requiresFullCalc, showGradient: $showGradient)
                default:
                    Text("Invalid selection")
                }
            }
            .padding(.top, 8) // Add some spacing
        }
        .padding()
    }
}

