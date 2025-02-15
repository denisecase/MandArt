import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct PanelDisplay: View {
  @EnvironmentObject var appState: AppState

  @State private var selectedTab = 0
  @State private var moved: Double = 0.0
  @State private var startTime: Date?

  var body: some View {
    VStack(alignment: .leading) {
      let viewModel = ImageViewModel(appState: appState)

      ScrollView([.horizontal, .vertical], showsIndicators: true) {
        if let cgImage = viewModel.getImage() {
          Image(decorative: cgImage, scale: 1.0)
            .frame(width: CGFloat(cgImage.width), height: CGFloat(cgImage.height))
            .gesture(tapGesture(for: appState.picdef))
        } else {
          Text("No Image Available")
            .foregroundColor(.gray)
        }
      }
    }
    .padding(2)
  }

  /// Tap Gesture that modifies the `picdef`'s center
  private func tapGesture(for picdef: PictureDefinition) -> some Gesture {
    DragGesture(minimumDistance: 0, coordinateSpace: .local)
      .onChanged { value in
        self.moved += value.translation.width + value.translation.height
        if self.startTime == nil {
          self.startTime = value.time
        }
      }
      .onEnded { tap in
        if self.moved < 2, self.moved > -2 {
          picdef.xCenter = getCenterXFromTap(tap, picdef: picdef)
          picdef.yCenter = getCenterYFromTap(tap, picdef: picdef)
        } else {
          picdef.xCenter = getCenterXFromDrag(tap, picdef: picdef)
          picdef.yCenter = getCenterYFromDrag(tap, picdef: picdef)
        }
        self.moved = 0
        self.startTime = nil
      }
  }

  /// Get new X center after a tap
  private func getCenterXFromTap(_ tap: _ChangedGesture<DragGesture>.Value, picdef: PictureDefinition) -> Double {
    let startX = tap.startLocation.x
    let w = Double(picdef.imageWidth)
    let movedX = (startX - w / 2.0)
    let diffX = movedX / picdef.scale
    return picdef.xCenter + diffX
  }

  /// Get new Y center after a tap
  private func getCenterYFromTap(_ tap: _ChangedGesture<DragGesture>.Value, picdef: PictureDefinition) -> Double {
    let startY = tap.startLocation.y
    let h = Double(picdef.imageHeight)
    let movedY = ((h - startY) - h / 2.0)
    let diffY = movedY / picdef.scale
    return picdef.yCenter + diffY
  }

  /// Get new X center after a drag
  private func getCenterXFromDrag(_ tap: _ChangedGesture<DragGesture>.Value, picdef: PictureDefinition) -> Double {
    let startX = tap.startLocation.x
    let endX = tap.location.x
    let movedX = -(endX - startX)
    let diffX = movedX / picdef.scale
    return picdef.xCenter + diffX
  }

  /// Get new Y center after a drag
  private func getCenterYFromDrag(_ tap: _ChangedGesture<DragGesture>.Value, picdef: PictureDefinition) -> Double {
    let startY = tap.startLocation.y
    let endY = tap.location.y
    let movedY = endY - startY
    let diffY = movedY / picdef.scale
    return picdef.yCenter + diffY
  }
}
