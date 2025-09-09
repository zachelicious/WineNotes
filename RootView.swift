import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Review.date, order: .reverse) private var reviews: [Review]
    @State private var showingNew = false
    @State private var queryText = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredReviews) { review in
                    NavigationLink(value: review.id) {
                        ReviewRow(review: review)
                    }
                }
            }
            .navigationTitle("Wine Notes")
            .searchable(text: $queryText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search producer, aromas…")
            .toolbar { bottomToolbar }
            .navigationDestination(for: UUID.self) { id in
                if let review = reviews.first(where: { $0.id == id }) {
                    ReviewDetailView(review: review)
                }
            }
        }
        .sheet(isPresented: $showingNew) {
            NewReviewView()
        }
    }

    var filteredReviews: [Review] {
        guard !queryText.isEmpty else { return reviews }
        let t = queryText.lowercased()
        return reviews.filter { r in
            let bottle = r.bottle
            return [bottle.producer, bottle.wineName, bottle.region ?? "", bottle.country ?? ""].joined(separator: " ").lowercased().contains(t) ||
                   r.aromas.joined(separator: " ").lowercased().contains(t)
        }
    }

    @ToolbarContentBuilder
    var bottomToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            Spacer()
            Button {
                showingNew = true
            } label: {
                Label("New review", systemImage: "plus.circle.fill")
                    .font(.title2)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

struct ReviewRow: View {
    let review: Review
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(review.bottle.vintage.map(String.init) ?? "NV") \(review.bottle.producer) – \(review.bottle.wineName)")
                .font(.headline)
                .lineLimit(1)
            if let note = review.generatedNote, !note.isEmpty {
                Text(note).font(.subheadline).lineLimit(2)
            } else if !review.aromas.isEmpty {
                Text(review.aromas.joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
}