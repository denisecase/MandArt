import AppKit
import SwiftUI
import SwiftData

/// View for the welcome screen informational content and show toggle.
@available(macOS 11.0, *)
struct WelcomeMainInformationView: View {
  @EnvironmentObject var appState: AppState
  let showWelcomeScreen: Bool
    let picdef: PictureDefinition
    
  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("MandArt is the ultimate app for creating custom art from the Mandelbrot set.")
        .font(.title3)
        .fixedSize(horizontal: false, vertical: false) // wrap

      Text(
        "Find an interesting location (for example, near where two black areas meet), zoom in and out, and customize the coloring. Nearby colors flow into one another, so check their gradients to see how the intermediate colors appear. If you'll print your art, choose from colors more likely to print true."
      )
      .fixedSize(horizontal: false, vertical: true) // wrap

      Button(action: {
          openDefaultMandArtDocument()

      }) {
        Text("Click here to open default MandArt document and get started")
          .fontWeight(.semibold)
      }
      .buttonStyle(.bordered)
      .controlSize(.large)

      Toggle(isOn: $appState.shouldShowWelcomeWhenStartingUp) {
        Text("Show welcome screen when starting")
      }
      .onTapGesture {
        // do nothing else
      }
      .onChange(of: appState.shouldShowWelcomeWhenStartingUp) { _, newValue in
        UserDefaults.standard.setValue(newValue, forKey: "shouldShowWelcomeWhenStartingUp")
      }
    }
    .padding()
  }
    
    /// Ensures a default MandArt document exists and opens ContentView
    private func openDefaultMandArtDocument() {
        if let window = NSApplication.shared.mainWindow {
            window.close() // Close the welcome screen
        }
        
        // Insert a default `PictureDefinition` into SwiftData if needed
        Task {
            do {
                let container = try ModelContainer(for: Schema([PictureDefinition.self]))
                let context = container.mainContext
                
                let existingPicdefs = try context.fetch(FetchDescriptor<PictureDefinition>())
                if existingPicdefs.isEmpty {
                    let newPicdef = PictureDefinition()
                    context.insert(newPicdef)
                    try context.save()
                }
                
                // Open ContentView in a new window
                let newWindow = NSWindow(
                    contentRect: NSRect(x: 0, y: 0, width: 1000, height: 800),
                    styleMask: [.titled, .closable, .resizable, .miniaturizable],
                    backing: .buffered,
                    defer: false
                )
                newWindow.center()
                newWindow.setFrameAutosaveName("MandArt Main Window")
                newWindow.contentView = NSHostingView(rootView: ContentView(picdef: picdef).environment(\.modelContext, context))
                newWindow.makeKeyAndOrderFront(nil)
            } catch {
                print("Error opening default MandArt document: \(error)")
            }
        }
    }

}
