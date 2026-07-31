import Foundation

struct VideoResponseDTO: Decodable {
    let results: [VideoDTO]
}

struct VideoDTO: Decodable {
    let id: String
    let key: String
    let site: String
    let type: String
    let official: Bool
}
