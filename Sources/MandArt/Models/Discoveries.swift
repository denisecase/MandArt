import Foundation
//
//{
//  "name": "AAA2",
//  "mandart_url": "https://raw.githubusercontent.com/denisecase/MandArt-Discoveries/main/brucehjohnson/_/AAA2.mandart",
//  "png_path": "thumbnails/AAA2.png"
//},

struct MandArtDiscovery: Identifiable, Codable {
  var id: UUID { UUID() }
  let name: String
  let mandart_url: String
  let png_path: String
}


// Function to load MandArt discoveries from JSON
func loadMandArtDiscoveries() -> [MandArtDiscovery] {
  guard let url = Bundle.main.url(forResource: "mandart_discoveries", withExtension: "json") else {
    print("File mandart_discoveries.json not found in the bundle.")
    return []
  }
  
  do {
    let data = try Data(contentsOf: url)
    let discoveries = try JSONDecoder().decode([MandArtDiscovery].self, from: data)
    return discoveries
  } catch {
    print("Error decoding JSON: \(error)")
    return []
  }
}
