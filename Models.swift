import Foundation
import SwiftData

@Model
final class Bottle {
    @Attribute(.unique) var id: UUID
    var producer: String
    var wineName: String
    var vintage: Int?
    var country: String?
    var region: String?
    var grapes: [String]
    var abv: Double?
    var imageData: Data?

    init(id: UUID = UUID(), producer: String = "", wineName: String = "", vintage: Int? = nil,
         country: String? = nil, region: String? = nil, grapes: [String] = [], abv: Double? = nil, imageData: Data? = nil) {
        self.id = id
        self.producer = producer
        self.wineName = wineName
        self.vintage = vintage
        self.country = country
        self.region = region
        self.grapes = grapes
        self.abv = abv
        self.imageData = imageData
    }
}

@Model
final class Review {
    @Attribute(.unique) var id: UUID
    var bottle: Bottle
    var date: Date
    var rating: Int
    var sweetness: Int
    var acidity: Int
    var tannin: Int
    var body: Int
    var finishLen: Int?
    var aromas: [String]
    var context: String?
    var price: Double?
    var generatedNote: String?

    init(id: UUID = UUID(), bottle: Bottle, date: Date = .now, rating: Int = 0,
         sweetness: Int = 0, acidity: Int = 0, tannin: Int = 0, body: Int = 0, finishLen: Int? = nil,
         aromas: [String] = [], context: String? = nil, price: Double? = nil, generatedNote: String? = nil) {
        self.id = id
        self.bottle = bottle
        self.date = date
        self.rating = rating
        self.sweetness = sweetness
        self.acidity = acidity
        self.tannin = tannin
        self.body = body
        self.finishLen = finishLen
        self.aromas = aromas
        self.context = context
        self.price = price
        self.generatedNote = generatedNote
    }
}