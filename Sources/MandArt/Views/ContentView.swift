import AppKit // keypress
import CoreGraphics // for image scrollview?
import Foundation // trig functions
import SwiftData
import SwiftUI // views
import UniformTypeIdentifiers

// Global variable to hold a reference to the CGImage used across the app
var contextImageGlobal: CGImage?

/// `ContentView` is the main view of the MandArt application, available on macOS 14.0 and later.
/// It provides the user interface for interacting with the Mandelbrot set art generation features of the app.
struct ContentView: View {
  @EnvironmentObject var appState: AppState
  @Environment(\.modelContext) private var modelContext
  @StateObject var popupManager = PopupManager()
  @State var requiresFullCalc = true
  @State var showGradient: Bool = false

  @State private var moved: Double = 0.0
  @State private var startTime: Date?
  @State private var previousPicdef: PictureDefinition?
  @State private var textFieldImageHeight: NSTextField = .init()
  @State private var textFieldY: NSTextField = .init()
  private let widthOfInputPanel: CGFloat = 400

  var body: some View {
    GeometryReader { _ in

      HStack(spacing: 0) {
        PanelUI(popupManager: popupManager)
          .frame(width: widthOfInputPanel)
          .fixedSize(horizontal: true, vertical: false)
          .onAppear {
            print("PanelUI appeared successfully.")
          }

        PanelDisplay()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .onAppear {
            print("PanelDisplay appeared successfully.")
          }
      }
      .overlay(
        Group {
          ContentViewPopups(popupManager: popupManager)
        }
      )
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .padding(.leading, 0)
      .alert(isPresented: $appState.showResetAlert) {
        Alert(
          title: Text("Reset MandArt to Default Drawing?"),
          message: Text(
            "This will delete your changes and reset to the default MandArt example. Are you sure you want to continue?"
          ),
          primaryButton: .destructive(Text("Reset")) {
            appState.resetMandArt()
          },
          secondaryButton: .cancel {
            appState.showResetAlert = false
          }
        )
      }
      .alert("Replace MandArt?", isPresented: $appState.showReplaceAlert) {
        Button("Cancel", role: .cancel) { appState.pendingReplacement = nil }
        Button("Replace", role: .destructive) { appState.confirmReplaceMandArt() }
      } message: {
        Text("Are you sure you want to replace the current MandArt with a new one?")
      }
    } // geo
    .onAppear {
      print("ContentView is fully loaded!")
      print("appState.picdef: \(appState.picdef)")
      print("appState.showGradient: \(appState.showGradient)")
      print("appState.requiresFullCalc: \(appState.requiresFullCalc)")
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  } // body

  /// Creates and inserts a new `PictureDefinition`
  func addNewPictureDefinition() {
    let newPicdef = PictureDefinition()
    modelContext.insert(newPicdef)
  }

  /// Updates an existing `PictureDefinition`
  private func updatePicdef(_ oldPicdef: PictureDefinition, with newPicdef: PictureDefinition) {
    oldPicdef.hues = newPicdef.hues
    oldPicdef.leftNumber = newPicdef.leftNumber
    oldPicdef.mandColor = newPicdef.mandColor
    oldPicdef.scale = newPicdef.scale
    oldPicdef.theta = newPicdef.theta
    oldPicdef.iterationsMax = newPicdef.iterationsMax
  }
}
