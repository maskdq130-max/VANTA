import SwiftUI

enum Tab: String, CaseIterable {
    case home = "house.fill", search = "magnifyingglass", library = "square.stack.fill"
}

struct RootView: View {
    @EnvironmentObject var player: PlayerState
    @State private var tab: Tab = .home
    @Namespace private var ns

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()

            Group {
                switch tab {
                case .home: HomeView()
                case .search: SearchView()
                case .library: LibraryView()
                }
            }
            .id(tab)
            .transition(.opacity.combined(with: .scale(scale: 0.98)))

            VStack(spacing: 0) {
                if player.current != nil && !player.expanded {
                    MiniPlayer(ns: ns)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                TabBar(tab: $tab)
            }

            if player.expanded {
                PlayerView(ns: ns)
                    .transition(.move(edge: .bottom))
                    .zIndex(2)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: tab)
        .animation(.spring(response: 0.55, dampingFraction: 0.85), value: player.expanded)
    }
}

struct TabBar: View {
    @Binding var tab: Tab
    @Namespace private var bar
    var body: some View {
        HStack {
            ForEach(Tab.allCases, id: \.self) { t in
                Button { tab = t; UIImpactFeedbackGenerator(style: .light).impactOccurred() } label: {
                    ZStack {
                        if tab == t {
                            Capsule().fill(.white).frame(width: 56, height: 36)
                                .matchedGeometryEffect(id: "pill", in: bar)
                        }
                        Image(systemName: t.rawValue)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(tab == t ? .black : .white.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.vertical, 10)
        .background(Color.black)
    }
}

struct MiniPlayer: View {
    @EnvironmentObject var player: PlayerState
    var ns: Namespace.ID
    var body: some View {
        if let t = player.current {
            HStack(spacing: 12) {
                ArtView(seed: t.seed)
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .matchedGeometryEffect(id: "cover", in: ns)
                VStack(alignment: .leading, spacing: 2) {
                    Text(t.title).font(.system(size: 15, weight: .bold))
                    Text(t.artist).font(.system(size: 12)).foregroundColor(.white.opacity(0.5))
                }
                Spacer()
                Button { player.toggle() } label: {
                    Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 20))
                        .contentTransition(.symbolEffect(.replace))
                        .frame(width: 40, height: 40)
                }
                Button { player.next() } label: {
                    Image(systemName: "forward.fill").font(.system(size: 18)).frame(width: 36, height: 40)
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 14).padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16).fill(Color(white: 0.1))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.12)))
            )
            .overlay(alignment: .bottom) {
                GeometryReader { g in
                    Capsule().fill(.white).frame(width: g.size.width * player.progress, height: 2)
                        .offset(y: g.size.height - 2)
                }.padding(.horizontal, 14)
            }
            .padding(.horizontal, 10)
            .onTapGesture { player.expanded = true }
        }
    }
}
