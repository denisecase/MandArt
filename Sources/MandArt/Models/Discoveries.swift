import Foundation

struct MandArtDiscovery: Identifiable, Codable {
  var id: UUID { UUID() }
  let name: String
  let url: String
}

func loadMandArtDiscoveries() -> [MandArtDiscovery] {
  guard let url = Bundle.main.url(forResource: "mandart_discoveries", withExtension: "json"),
        let data = try? Data(contentsOf: url),
        let discoveries = try? JSONDecoder().decode([MandArtDiscovery].self, from: data)
  else {
    print("Failed to load MandArt discoveries")
    return []
  }
  return discoveries
}
