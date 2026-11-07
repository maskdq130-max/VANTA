import SwiftUI

/// Генеративная чёрно-белая обложка по seed
struct ArtView: View {
    let seed: Int
    var body: some View {
        Canvas { ctx, size in
            let full = CGRect(origin: .zero, size: size)
            ctx.fill(Path(full), with: .color(.black))
            let m = min(size.width, size.height)
            let n = 4 + seed % 5
            switch seed % 3 {
            case 0:
                for i in 0..<n {
                    let r = m * 0.5 * (1 - Double(i) / Double(n))
                    let rect = CGRect(x: size.width / 2 - r, y: size.height / 2 - r, width: r * 2, height: r * 2)
                    ctx.fill(Path(ellipseIn: rect), with: .color(i % 2 == 0 ? .white : .black))
                }
            case 1:
                let rows = n * 2
                let h = size.height / Double(rows)
                for i in 0..<rows {
                    let w = size.width * (0.3 + 0.7 * abs(sin(Double(seed * 7 + i))))
                    ctx.fill(Path(CGRect(x: 0, y: Double(i) * h, width: w, height: h * 0.55)), with: .color(.white))
                }
            default:
                let cols = n + 2
                let step = m / Double(cols)
                for x in 0..<cols {
                    for y in 0..<cols {
                        let d = (0.25 + 0.75 * abs(sin(Double(x * 3 + y * 5 + seed)))) * step * 0.8
                        let rect = CGRect(x: Double(x) * step + (step - d) / 2, y: Double(y) * step + (step - d) / 2, width: d, height: d)
                        ctx.fill(Path(ellipseIn: rect), with: .color(.white))
                    }
                }
            }
        }
        .drawingGroup()
    }
}
