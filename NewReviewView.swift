import SwiftUI
import SwiftData
import PhotosUI

struct NewReviewView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var producer = ""
    @State private var wineName = ""
    @State private var vintage: Int? = nil
    @State private var region = ""
    @State private var country = ""
    @State private var grapes: [String] = []

    @State private var rating: Double = 90
    @State private var sweetness = 0
    @State private var acidity = 2
    @State private var tannin = 2
    @State private var body = 2
    @State private var finishLen = 2

    @State private var aromas: [String] = ["cherry","violet","clove"]
    @State private var newAroma = ""
    @State private var contextNote = ""
    @State private var price: Double? = nil

    @State private var image: PhotosPickerItem? = nil
    @State private var imageData: Data? = nil

    @State private var isGenerating = false
    @State private var generatedNote: String? = nil
    @State private var error: String? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    PhotosPicker(selection: $image, matching: .images) {
                        ZStack { RoundedRectangle(cornerRadius: 16).strokeBorder(style: StrokeStyle(lineWidth: 1))
                            .frame(height: 140)
                            .overlay(Text("Add label photo").bold()) }
                    }
                    .onChange(of: image) { _, item in
                        Task { imageData = try? await item?.loadTransferable(type: Data.self) }
                    }

                    Group {
                        TextField("Producer", text: $producer).textContentType(.organizationName)
                        TextField("Wine name", text: $wineName)
                        HStack {
                            TextField("Vintage", value: $vintage, format: .number).keyboardType(.numberPad)
                            TextField("Region", text: $region)
                            TextField("Country", text: $country)
                        }
                    }
                    .textFieldStyle(.roundedBorder)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Rating: \(Int(rating))").font(.headline)
                        Slider(value: $rating, in: 70...100, step: 1)
                    }

                    traitRow(title: "Sweetness", value: $sweetness, labels: ["Dry","Off‑dry","Medium","Sweet","Luscious"])
                    traitRow(title: "Acidity", value: $acidity, labels: ["Low","Med‑","Med","Med+","High"])
                    traitRow(title: "Tannin", value: $tannin, labels: ["Low","Med‑","Med","Med+","High"])
                    traitRow(title: "Body", value: $body, labels: ["Light","Med‑","Med","Med+","Full"])
                    traitRow(title: "Finish", value: $finishLen, labels: ["Short","Med‑","Med","Med+","Long"])

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Aromas").font(.headline)
                        FlowLayout(alignment: .leading, spacing: 8) {
                            ForEach(aromas, id: \.self) { a in
                                Chip(text: a) { aromas.removeAll { $0 == a } }
                            }
                        }
                        HStack {
                            TextField("Add aroma", text: $newAroma)
                                .textFieldStyle(.roundedBorder)
                            Button("Add") {
                                let t = newAroma.trimmingCharacters(in: .whitespaces)
                                if !t.isEmpty { aromas.append(t); newAroma = "" }
                            }
                            .buttonStyle(.bordered)
                        }
                    }

                    TextField("Context (meal, venue)", text: $contextNote)
                        .textFieldStyle(.roundedBorder)
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack { Spacer()
                        Button(action: save) {
                            Label("Save", systemImage: "tray.and.arrow.down.fill").font(.title3)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(producer.isEmpty && wineName.isEmpty)

                        Button(action: generate) {
                            if isGenerating { ProgressView() } else { Label("Generate note", systemImage: "wand.and.stars") }
                        }
                        .buttonStyle(.bordered)
                        .disabled(isGenerating || (producer.isEmpty && wineName.isEmpty))
                    }
                }
            }
            .navigationTitle("New review")
            .alert("Error", isPresented: .constant(error != nil), actions: { Button("OK") { error = nil } }, message: { Text(error ?? "") })
        }
    }

    func save() {
        let bottle = Bottle(producer: producer, wineName: wineName, vintage: vintage,
                            country: country.isEmpty ? nil : country,
                            region: region.isEmpty ? nil : region,
                            grapes: grapes,
                            imageData: imageData)
        let review = Review(bottle: bottle, rating: Int(rating), sweetness: sweetness, acidity: acidity, tannin: tannin, body: body, finishLen: finishLen,
                            aromas: aromas, context: contextNote, price: price, generatedNote: generatedNote)
        context.insert(bottle)
        context.insert(review)
        do { try context.save() } catch { print(error) }
        SpotlightIndexer.index(review: review)
        dismiss()
    }

    func generate() {
        isGenerating = true
        Task {
            do {
                let note = try await LLMService.shared.generateNote(
                    producer: producer, wineName: wineName, vintage: vintage,
                    country: country, region: region, grapes: grapes,
                    rating: Int(rating), sweetness: sweetness, acidity: acidity, tannin: tannin, body: body, finishLen: finishLen,
                    aromas: aromas, context: contextNote)
                generatedNote = note
            } catch { self.error = error.localizedDescription }
            isGenerating = false
        }
    }
}

// Reusable controls
struct Chip: View {
    let text: String; var onRemove: (() -> Void)?
    var body: some View {
        HStack(spacing: 6) {
            Text(text).padding(.horizontal, 10).padding(.vertical, 6)
            if let onRemove { Button(action: onRemove) { Image(systemName: "xmark.circle.fill") } }
        }
        .background(Capsule().strokeBorder())
    }
}

struct FlowLayout<Content: View>: View {
    let alignment: HorizontalAlignment
    let spacing: CGFloat
    @ViewBuilder var content: Content
    init(alignment: HorizontalAlignment = .leading, spacing: CGFloat = 8, @ViewBuilder content: () -> Content) {
        self.alignment = alignment; self.spacing = spacing; self.content = content()
    }
    var body: some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        return GeometryReader { geo in
            ZStack(alignment: Alignment(horizontal: alignment, vertical: .top)) {
                content
                    .alignmentGuide(.leading) { d in
                        if (abs(width - d.width) > geo.size.width) { width = 0; height -= (d.height + spacing) }
                        let result = width
                        width -= d.width + spacing
                        return result
                    }
                    .alignmentGuide(.top) { d in let res = height; return res }
            }
        }.frame(maxWidth: .infinity, minHeight: 10)
    }
}

@ViewBuilder
func traitRow(title: String, value: Binding<Int>, labels: [String]) -> some View {
    VStack(alignment: .leading) {
        HStack { Text(title).font(.headline); Spacer(); Text(labels[value.wrappedValue]) }
        HStack {
            ForEach(0..<labels.count, id: \.self) { i in
                Button("\(i)") { value.wrappedValue = i }
                    .buttonStyle(.bordered)
            }
        }
    }
}