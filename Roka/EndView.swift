// EndView.swift
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
                .font(.custom("AmericanTypewriter-Bold", size: 26, relativeTo: .title2))
                .foregroundColor(RokaColor.ink)
                .padding(.bottom, 8)

            Text("\(score) / \(total)")
                .font(.custom("AmericanTypewriter-Bold", size: 64, relativeTo: .largeTitle))
                .foregroundColor(RokaColor.tan)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .padding(.bottom, 16)

            // Result dots
            let columns = Array(repeating: GridItem(.fixed(44), spacing: 0), count: 10)
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(Array(results.enumerated()), id: \.offset) { index, r in
                    ZStack {
                        if r.correct {
                            Circle()
                                .fill(RokaColor.correct)
                                .frame(width: 14, height: 14)
                        } else {
                            Rectangle()
                                .fill(RokaColor.wrong)
                                .frame(width: 11, height: 11)
                                .rotationEffect(.degrees(45))
                        }
                    }
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                    .accessibilityLabel(r.correct
                        ? "Word \(index + 1): correct"
                        : "Word \(index + 1): incorrect")
                    .accessibilityAddTraits(.isImage)
                }
            }
            .frame(maxWidth: 440)
            .padding(.bottom, 14)

            Text(message)
                .font(.custom("AmericanTypewriter", size: 16, relativeTo: .body))
                .foregroundColor(RokaColor.inkLight)
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
