import SwiftUI

struct ReviewDetailView: View {
    let review: Review
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("\(review.bottle.vintage.map(String.init) ?? "NV") \(review.bottle.producer) – \(review.bottle.wineName)")
                    .font(.title2).bold()
                if let note = review.generatedNote, !note.isEmpty {
                    Text(note).font(.body)
                }
                if !review.aromas.isEmpty {
                    Text("Aromas: " + review.aromas.joined(separator: ", "))
                        .foregroundStyle(.secondary)
                }
                Text("Rating: \(review.rating)")
                Text("Structure: S\(review.sweetness) A\(review.acidity) T\(review.tannin) B\(review.body) F\(review.finishLen ?? 0)")
            }
            .padding()
        }
        .navigationTitle("Details")
    }
}