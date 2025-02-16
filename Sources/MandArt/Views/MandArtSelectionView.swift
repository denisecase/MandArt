import SwiftUI

struct MandArtSelectionView: View {
  @Environment(\.presentationMode) var presentationMode
  let discoveries: [MandArtDiscovery]
  let onSelect: (MandArtDiscovery) -> Void

  let columns = [
    GridItem(.adaptive(minimum: 100)), // Adaptive grid layout
  ]

  var body: some View {
    VStack {
      Text("Select MandArt")
        .font(.title)
        .padding()

      ScrollView {
        LazyVGrid(columns: columns, spacing: 20) {
          ForEach(discoveries) { discovery in
            VStack {
              let fileName = URL(fileURLWithPath: discovery.png_path).lastPathComponent
              if let imagePath = Bundle.main.path(forResource: fileName, ofType: nil, inDirectory: "MandArt_Catalog"),
                 let nsImage = NSImage(contentsOfFile: imagePath) {
                Image(nsImage: nsImage)
                  .resizable()
                  .scaledToFit()
                  .frame(width: 100, height: 100)
                  .clipShape(RoundedRectangle(cornerRadius: 10))
                  .shadow(radius: 5)
                  .onTapGesture {
                    onSelect(discovery)
                    presentationMode.wrappedValue.dismiss()
                  }
              } else {
                Text("Image not found")
                  .foregroundColor(.red)
                  .frame(width: 100, height: 100)
              }

              Text(discovery.name)
                .font(.caption)
                .multilineTextAlignment(.center)
            }
          }
        }
        .padding()
      }

      Button("Cancel") {
        presentationMode.wrappedValue.dismiss()
      }
      .padding()
    }
  }
}
