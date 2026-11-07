import SwiftUI

struct SearchView: View {
    @EnvironmentObject var player: PlayerState
    @State private var query = ""
    var results: [Track] {
        query.isEmpty ? Track.samples :
        Track.samples.filter { $0.title.localizedCaseInsensitiveContains(query) || $0.artist.localizedCaseInsensitiveContains(query) }
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Поиск").font(.system(size: 30, weight: .black)).padding(.top, 20)
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Треки, артисты", text: $query)
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.25)))
            ScrollView(showsIndicators: false) {
                VStack(spacing: 4) {
                    ForEach(results) { t in
                        Button { player.play(t) } label: {
                            HStack(spacing: 12) {
                                ArtView(seed: t.seed).frame(width: 48, height: 48)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                VStack(alignment: .leading) {
                                    Text(t.title).font(.system(size: 15, weight: .bold))
                                    Text(t.artist).font(.system(size: 12)).foregroundColor(.white.opacity(0.5))
                                }
                                Spacer()
                                Text(timeString(t.duration)).font(.system(size: 12)).foregroundColor(.white.opacity(0.4))
                            }
                            .padding(.vertical, 6)
                        }
                        .buttonStyle(PressStyle())
                        .transition(.opacity.combined(with: .move(edge: .leading)))
                    }
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.85), value: results)
                .padding(.bottom, 160)
            }
        }
        .padding(.horizontal, 20)
        .foregroundColor(.white)
    }
}

struct LibraryView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart.fill").font(.system(size: 44))
            Text("Коллекция").font(.system(size: 26, weight: .black))
            Text("Скоро здесь будут твои треки").foregroundColor(.white.opacity(0.5))
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
