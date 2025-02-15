import SwiftUI

@available(macOS 12.0, *)
struct PopupColorSlice: View {
  @EnvironmentObject var appState: AppState
  @Binding var selectedColor: (r: Int, g: Int, b: Int)?

  let arrColors: [Color]
  let start: Int
  let end: Int

  init(
    selectedColor: Binding<(r: Int, g: Int, b: Int)?>,
    arrColors: [Color],
    start: Int,
    end: Int
  ) {
    _selectedColor = selectedColor
    self.arrColors = arrColors
    self.start = start
    self.end = end
  }

  /// Handles color selection, updates `selectedColor`, and adds the hue to `picdef`
  private func handleColorSelection(color: Color) {
    if let components = color.colorComponents {
      let newColor = (r: Int(components.red * 255), g: Int(components.green * 255), b: Int(components.blue * 255))
      selectedColor = newColor
      appState.picdef.addHue(r: Double(newColor.r), g: Double(newColor.g), b: Double(newColor.b))
    }
  }

  var body: some View {
    let (nColumns, nRows) = arrColors.count == 512 ? (8, 8) : (9, 9) // Dynamically set grid size

    VStack(spacing: 0) {
      ForEach(0 ..< nRows, id: \.self) { row in
        HStack(spacing: 0) {
          ForEach(0 ..< nColumns, id: \.self) { col in
            let index = start + row * nColumns + col

            Button(action: {
              if index <= end {
                handleColorSelection(color: arrColors[index])
              }
            }) {
              Rectangle()
                .fill(index <= end ? arrColors[index] : Color.clear)
                .frame(width: arrColors.count == 512 ? 30 : 20, height: arrColors.count == 512 ? 30 : 20)
                .cornerRadius(4)
                .padding(1)
            }
            .buttonStyle(PlainButtonStyle())
          }
        }
      }
    }
  }
}
