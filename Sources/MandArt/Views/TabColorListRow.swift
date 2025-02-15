import SwiftUI
import UniformTypeIdentifiers

/// A view representing a row in the color list.
struct TabColorListRow: View {
  @EnvironmentObject var appState: AppState
  @State private var showingPrintablePopups = false

  let index: Int

  var body: some View {
    if appState.picdef.isHueIndexValid(index) {
      HStack {
        Image(systemName: "line.horizontal.3")
          .foregroundColor(.secondary)

        Text(String(appState.picdef.rowNumber(for: index)))

        ColorPicker(
          "",
          selection: Binding<Color>(
            get: {
              guard appState.picdef.isHueIndexValid(index) else {
                return Color.black // Fallback color in case index is invalid
              }
              return appState.picdef.hues[index].color
            },
            set: { newColor in
              appState.picdef.updateHueWithColorPick(
                index: index,
                newColorPick: newColor,
                undoManager: appState.undoManager
              )
            }
          ),
          supportsOpacity: false
        )

        Button {
          showingPrintablePopups = true
        } label: {
          Image(systemName: "exclamationmark.circle")
            .opacity(appState.picdef.isPrintableColor(at: index) ? 0 : 1)
        }
        .opacity(appState.picdef.isPrintableColor(at: index) ? 0 : 1)
        .help("See printable options for \(appState.picdef.rowNumber(for: index))")

        Text(String(format: "%03d", Int(appState.picdef.hues[index].r)))
        Text(String(format: "%03d", Int(appState.picdef.hues[index].g)))
        Text(String(format: "%03d", Int(appState.picdef.hues[index].b)))

        Button(role: .destructive) {
          appState.picdef.removeHue(at: index)
          appState.picdef.updateHueNumbers()
        } label: {
          Image(systemName: "trash")
        }
        .help("Delete \(appState.picdef.rowNumber(for: index))")

        Spacer()
      }
    }
  }
}
