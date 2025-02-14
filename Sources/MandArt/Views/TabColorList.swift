import SwiftUI
import UniformTypeIdentifiers

struct TabColorList: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        GeometryReader { geometry in
            List {
                ForEach(appState.picdef.hues.indices, id: \.self) { index in
                    TabColorListRow(index: index)
                }
                .onMove(perform: moveHues)
            }
            .frame(height: geometry.size.height)
        }
        .onAppear {
            appState.updateRequiresFullCalc(false)
        }
        .frame(maxHeight: .infinity)
    }
    
    /// Handles the reordering of hues within the document.
    ///
    /// When hues are moved in the list, this function updates their order in the `MandArtDocument`.
    /// It also reassigns the hue numbers to reflect the new order.
    ///
    /// - Parameters:
    ///   - source: An `IndexSet` indicating the original positions of the moved hues.
    ///   - destination: An `Int` representing the new position for the moved hues.
    func moveHues(from source: IndexSet, to destination: Int) {
        appState.picdef.hues.move(fromOffsets: source, toOffset: destination)
        for (index, _) in appState.picdef.hues.enumerated() {
            appState.picdef.hues[index].num = index + 1
        }
    }
}
