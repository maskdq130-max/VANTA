import SwiftUI

struct PlayerView: View {
    @EnvironmentObject var player: PlayerState
    var ns: Namespace.ID
    @State private var drag: CGFloat = 0

    var body: some View {
        if let t = player.current {
            ZStack {
                Color.black.ignoresSafeArea()
                ArtView(seed: t.seed)
                    .scaleEffect(3).blur(radius: 60).opacity(0.22)
                    .ignoresSafeArea()
                    .id(t.id)
                    .transition(.opacity)

                VStack(spacing: 26) {
                    Capsule().fill(.white.opacity(0.3)).frame(width: 40, height: 5).padding(.top, 8)
                    Spacer(minLength: 0)

                    ArtView(seed: t.seed)
                        .aspectRatio(1, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        .overlay(RoundedRectangle(cornerRadius: 22).stroke(.white.opacity(0.2)))
                        .matchedGeometryEffect(id: "cover", in: ns)
                        .scaleEffect(player.isPlaying ? 1 : 0.82)
                        .shadow(color: .white.opacity(player.isPlaying ? 0.15 : 0), radius: 40)
                        .padding(.horizontal, 36)

                    Equalizer(active: player.isPlaying).frame(height: 36).padding(.horizontal, 36)

                    VStack(spacing: 6) {
                        Text(t.title).font(.system(size: 26, weight: .black))
                        Text(t.artist).font(.system(size: 16)).foregroundColor(.white.opacity(0.55))
                    }
                    .id(t.id)
                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                            removal: .move(edge: .leading).combined(with: .opacity)))

                    ProgressBar(progress: $player.progress, duration: t.duration)
                        .padding(.horizontal, 36)

                    HStack(spacing: 44) {
                        Button { player.prev() } label: { Image(systemName: "backward.fill").font(.system(size: 26)) }
                        Button { player.toggle() } label: {
                            ZStack {
                                Circle().fill(.white).frame(width: 78, height: 78)
                                Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 30)).foregroundColor(.black)
                            }
                        }
                        Button { player.next() } label: { Image(systemName: "forward.fill").font(.system(size: 26)) }
                    }
                    .buttonStyle(PressStyle())
                    Spacer(minLength: 0)
                }
                .foregroundColor(.white)
            }
            .offset(y: drag)
            .gesture(
                DragGesture()
                    .onChanged { drag = max(0, $0.translation.height) }
                    .onEnded { v in
                        if v.translation.height > 140 { player.expanded = false }
                        withAnimation(.spring()) { drag = 0 }
                    }
            )
        }
    }
}

struct Equalizer: View {
    let active: Bool
    var body: some View {
        TimelineView(.animation) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate
            HStack(spacing: 4) {
                ForEach(0..<28, id: \.self) { i in
                    let v = active ? 0.15 + 0.85 * abs(sin(t * (2.2 + Double(i % 5) * 0.6) + Double(i))) : 0.08
                    Capsule().fill(.white).frame(height: 36 * v)
                        .frame(maxHeight: 36, alignment: .center)
                }
            }
            .animation(.easeOut(duration: 0.3), value: active)
        }
    }
}

struct ProgressBar: View {
    @Binding var progress: Double
    let duration: Double
    @State private var dragging = false
    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.2))
                    Capsule().fill(.white).frame(width: g.size.width * progress)
                }
                .frame(height: dragging ? 10 : 5)
                .frame(maxHeight: .infinity)
                .contentShape(Rectangle())
                .gesture(DragGesture(minimumDistance: 0)
                    .onChanged { v in
                        withAnimation(.spring(response: 0.3)) { dragging = true }
                        progress = min(1, max(0, v.location.x / g.size.width))
                    }
                    .onEnded { _ in withAnimation(.spring(response: 0.3)) { dragging = false } })
            }
            .frame(height: 20)
            HStack {
                Text(timeString(progress * duration))
                Spacer()
                Text("-" + timeString(duration * (1 - progress)))
            }
            .font(.system(size: 12, weight: .medium).monospacedDigit())
            .foregroundColor(.white.opacity(0.5))
        }
    }
}
