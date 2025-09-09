import CoreSpotlight
import MobileCoreServices

enum SpotlightIndexer {
    static func index(review: Review) {
        let title = "\(review.bottle.vintage.map(String.init) ?? "NV") \(review.bottle.producer) – \(review.bottle.wineName)"
        let content = (review.generatedNote?.isEmpty == false ? review.generatedNote! : review.aromas.joined(separator: ", "))
        let attrSet = CSSearchableItemAttributeSet(contentType: .text)
        attrSet.title = title
        attrSet.contentDescription = content
        attrSet.keywords = [review.bottle.producer, review.bottle.wineName] + review.aromas
        let item = CSSearchableItem(uniqueIdentifier: review.id.uuidString, domainIdentifier: "wine.review", attributeSet: attrSet)
        CSSearchableIndex.default().indexSearchableItems([item]) { error in
            if let error { print("Spotlight index error: \(error)") }
        }
    }
}