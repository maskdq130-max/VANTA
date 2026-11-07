import SwiftUI

struct HomeView: View {
    @EnvironmentObject var player: PlayerState
    @State private var appeared = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                Text("VANTA")
                    .font(.system(size: 34, weight: .black))
                    .tracking(appeared ? 8 : 30)
                    .opacity(appeared ? 1 : 0)
                    .padding(.top, 20)

                WaveButton { player.play(Track.samples[0]) }
                    .frame(maxWidth: .infinity)
                    .opacity(appeared ? 1 : 0)
                    .scaleEffect(appeared ? 1 : 0.6)

                Section2(title: "Для вас", tracks: Track.samples, base: 0, appeared: appeared)
                Section2(title: "Новинки", tracks: Array(Track.samples.reversed()), base: 8, appeared: appeared)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 160)
        }
        .foregroundColor(.white)
        .onAppear { withAnimation(.spring(response: 0.9, dampingFraction: 0.75)) { appeared = true } }
    }
}

struct Section2: View {
    @EnvironmentObject var player: PlayerState
    let title: String
    let tracks: [Track]
    let base: Int
    let appeared: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title).font(.system(size: 22, weight: .heavy))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(Array(tracks.enumerated()), id: \.element.id) { i, t in
                        Button { player.play(t) } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                ArtView(seed: t.seed)
                                    .frame(width: 140, height: 140)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.15)))
                                Text(t.title).font(.system(size: 14, weight: .bold)).lineLimit(1)
                                Text(t.artist).font(.system(size: 12)).foregroundColor(.white.opacity(0.5))
                            }
                            .frame(width: 140, alignment: .leading)
                        }
                        .buttonStyle(PressStyle())
                        .offset(x: appeared ? 0 : 80)
                        .opacity(appeared ? 1 : 0)
                        .animation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.25 + Double(i) * 0.06), value: appeared)
                    }
                }
            }
        }
    }
}

struct PressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.93 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

/// «Моя волна» — пульсирующие кольца
struct WaveButton: View {
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            TimelineView(.animation) { tl in
                let t = tl.date.timeIntervalSinceReferenceDate
                ZStack {
                    ForEach(0..<3) { i in
                        let p = (t * 0.5 + Double(i) / 3).truncatingRemainder(dividingBy: 1)
                        Circle().stroke(.white.opacity(1 - p), lineWidth: 1.5)
                            .frame(width: 90 + 150 * p, height: 90 + 150 * p)
                    }
                    Circle().fill(.white).frame(width: 90, height: 90)
                        .scaleEffect(1 + 0.04 * sin(t * 3))
                    Text("ВОЛНА").font(.system(size: 13, weight: .black)).tracking(2).foregroundColor(.black)
                }
                .frame(height: 250)
            }
        }
        .buttonStyle(PressStyle())
    }
}
