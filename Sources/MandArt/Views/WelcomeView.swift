import AppKit
import SwiftUI

@available(macOS 11.0, *)
enum Constants {
  static let windowHeight: CGFloat = 460
  static let windowWidth: CGFloat = 667
  static let imageHeightFactor: CGFloat = 0.5
  static let descriptionHeightFactor: CGFloat = 0.3
}

struct WelcomeView: View {
  @EnvironmentObject var appState: AppState
    @State private var scale: CGFloat = 1
    @State private var angle: Double = 0
  let picdef: PictureDefinition

  var body: some View {
    VStack(spacing: 0) {
        VStack(spacing: 10) {
            Text("Welcome to MandArt")
                .font(.title)
                .fontWeight(.bold)
            Spacer().frame(height: 10)
        }
        .padding()
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Image("Welcome")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: Constants.windowHeight / 2)
                    .cornerRadius(20)
                    .scaleEffect(scale)
                    .rotationEffect(.degrees(angle))
                    .onAppear {
                        angle = -10
                        withAnimation(Animation.interpolatingSpring(mass: 1, stiffness: 50, damping: 5, initialVelocity: 0)) {
                            angle = 10
                            scale = 1.1
                        }
                        withAnimation(Animation.interpolatingSpring(mass: 1, stiffness: 50, damping: 10, initialVelocity: 0)) {
                            angle = -5
                            scale = 0.9
                        }
                        
                        withAnimation(Animation.interpolatingSpring(mass: 1, stiffness: 50, damping: 10, initialVelocity: 0)) {
                            angle = 0
                            scale = 1.0
                        }
                    }
                    .frame(height: geometry.size.height * Constants.imageHeightFactor)
                
                WelcomeMainInformationView(
                    showWelcomeScreen: appState.shouldShowWelcomeWhenStartingUp,
                    picdef: picdef
                )
                    .frame(maxHeight: .infinity) // all  vertical space
                    .padding()
            }
        }    }
    .padding()
    .frame(minWidth: Constants.windowWidth, minHeight: Constants.windowHeight)
    .ignoresSafeArea()
    .overlay(
      GeometryReader { geometry in
        Color.clear
          .preference(key: ViewSizeKey.self, value: geometry.size)
      }
    )
    .onPreferenceChange(ViewSizeKey.self) { size in
      updateWindowFrame(with: size)
    }
  }

  private func updateWindowFrame(with _: CGSize) {
    // Code to update window frame based on size
  }

  var screenSize: CGSize {
    // Fetching the main screen's size
    guard let screen = NSScreen.main else {
      return CGSize(width: Constants.windowWidth, height: Constants.windowHeight)
    }
    return screen.frame.size
  }
}

@available(macOS 11.0, *)
struct ViewSizeKey: PreferenceKey {
  static var defaultValue: CGSize = .zero

  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
    value = nextValue()
  }
}
