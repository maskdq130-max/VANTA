import SwiftUI

struct Track: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let artist: String
    let seed: Int
    let duration: Double

    static let samples: [Track] = [
        Track(title: "Night Drive", artist: "Monochrome", seed: 0, duration: 212),
        Track(title: "Static Bloom", artist: "Ash & Ivory", seed: 1, duration: 187),
        Track(title: "Black Mirror", artist: "VOID", seed: 2, duration: 240),
        Track(title: "Paper Moon", artist: "Grey Hours", seed: 3, duration: 198),
        Track(title: "Echo Chamber", artist: "Noir", seed: 4, duration: 225),
        Track(title: "Slow Burn", artist: "Charcoal", seed: 5, duration: 205),
        Track(title: "Afterglow", artist: "Ash & Ivory", seed: 6, duration: 176),
        Track(title: "Hollow", artist: "VOID", seed: 7, duration: 233)
    ]
}

final class PlayerState: ObservableObject {
    @Published var current: Track?
    @Published var isPlaying = false
    @Published var progress: Double = 0
    @Published var expanded = false
    private var timer: Timer?
    let queue = Track.samples

    func play(_ t: Track) {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            current = t
            isPlaying = true
        }
        progress = 0
        startTimer()
    }

    func toggle() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) { isPlaying.toggle() }
        isPlaying ? startTimer() : timer?.invalidate()
    }

    func next() { step(1) }
    func prev() { step(-1) }

    private func step(_ d: Int) {
        guard let c = current, let i = queue.firstIndex(of: c) else { return }
        play(queue[(i + d + queue.count) % queue.count])
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self, let c = self.current, self.isPlaying else { return }
            self.progress += 0.1 / c.duration
            if self.progress >= 1 { self.next() }
        }
    }
}

func timeString(_ s: Double) -> String {
    let t = Int(max(0, s))
    return String(format: "%d:%02d", t / 60, t % 60)
}
