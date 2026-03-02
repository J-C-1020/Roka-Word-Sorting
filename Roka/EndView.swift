import SwiftUI

struct EndView: View {
    let results: [RoundResult]
    let levelTitle: String
    let onRestart: () -> Void
    let onHome: () -> Void
    let onLevels: () -> Void

    private var score: Int { results.filter(\.correct).count }
    private var total: Int { results.count }

    private var message: String {
        let pct = Double(score) / Double(max(total, 1))
        if pct == 1.0 { return "Perfect! You're a Roka master. 🏆" }
        if pct >= 0.8  { return "Great job! Almost flawless. ✨" }
        if pct >= 0.6  { return "Good effort! Keep sorting. 📚" }
        return "The Rokas fooled you… try again! 🃏"
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text(levelTitle + " — Done!")
                .font(RokaFont.boldScaled(.title2, base: 22))
                .foregroundColor(RokaColor.ink)
                .padding(.bottom, 8)

            Text("\(score) / \(total)")
                .font(RokaFont.boldScaled(.largeTitle, base: 60))
                .foregroundColor(RokaColor.tan)
                .padding(.bottom, 16)

            // Result dots — use both shape+fill for "differentiate without color"
            let columns = Array(repeating: GridItem(.fixed(16), spacing: 8), count: 10)
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(Array(results.enumerated()), id: \.offset) { _, r in
                    if r.correct {
                        Circle()
                            .fill(RokaColor.correct)
                            .frame(width: 14, height: 14)
                            .accessibilityLabel("Correct")
                    } else {
                        // Diamond shape for wrong — "differentiate without color"
                        Rectangle()
                            .fill(RokaColor.wrong)
                            .frame(width: 12, height: 12)
                            .rotationEffect(.degrees(45))
                            .accessibilityLabel("Incorrect")
                    }
                }
            }
            .frame(maxWidth: 220)
            .padding(.bottom, 14)

            Text(message)
                .font(RokaFont.regularScaled(.body, base: 16))
                .foregroundColor(RokaColor.inkSubtle)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 32)

            VStack(spacing: 10) {
                RokaPrimaryButton(title: "Play Again", action: onRestart)
                RokaSecondaryButton(title: "Choose Level", action: onLevels)
                RokaSecondaryButton(title: "Home", action: onHome)
            }
            .frame(maxWidth: 260)

            Spacer()
        }
        .padding(.horizontal, 40)
        .transition(.opacity.combined(with: .scale(scale: 0.97)))
    }
}
