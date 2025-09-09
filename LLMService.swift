import Foundation

struct LLMRequest: Codable {
    var producer: String
    var wineName: String
    var vintage: Int?
    var country: String
    var region: String
    var grapes: [String]
    var rating: Int
    var sweetness: Int
    var acidity: Int
    var tannin: Int
    var body: Int
    var finishLen: Int?
    var aromas: [String]
    var context: String
}

actor LLMService {
    static let shared = LLMService()
    private let endpoint = URL(string: "https://YOUR_WORKER_URL/notes")!

    func generateNote(producer: String, wineName: String, vintage: Int?, country: String, region: String, grapes: [String], rating: Int, sweetness: Int, acidity: Int, tannin: Int, body: Int, finishLen: Int?, aromas: [String], context: String) async throws -> String {
        let payload = LLMRequest(producer: producer, wineName: wineName, vintage: vintage, country: country, region: region, grapes: grapes, rating: rating, sweetness: sweetness, acidity: acidity, tannin: tannin, body: body, finishLen: finishLen, aromas: aromas, context: context)
        var req = URLRequest(url: endpoint)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(payload)

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        struct R: Decodable { let note: String }
        let result = try JSONDecoder().decode(R.self, from: data)
        return result.note
    }
}