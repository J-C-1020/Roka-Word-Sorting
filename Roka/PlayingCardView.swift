import SwiftUI

// MARK: - PlayingCardView (in-game card)

struct PlayingCardView: View {
    let word: String
    let isVisible: Bool

    @State private var cardOffset: CGFloat = 0
    @State private var cardOpacity: Double = 1
    @State private var cardRotation: Double = 0
    @State private var cardScale: Double = 1

    var body: some View {
        ZStack {
            // Back cards — decorative stack effect, no content
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 0.96, green: 0.94, blue: 0.91))
                .frame(width: 220, height: 145)
                .shadow(color: .black.opacity(0.1), radius: 3, x: 1, y: 2)
                .rotationEffect(.degrees(-4))
                .offset(x: -3, y: 5)
                .accessibilityHidden(true)

            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 0.96, green: 0.94, blue: 0.91))
                .frame(width: 220, height: 145)
                .shadow(color: .black.opacity(0.1), radius: 3, x: 1, y: 2)
                .rotationEffect(.degrees(2.5))
                .offset(x: 3, y: 3)
                .accessibilityHidden(true)

            // Front card — the only meaningful element
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.18), radius: 8, x: 3, y: 5)

                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(white: 0.86), lineWidth: 1.5)

                Text(word)
                    .font(.custom("AmericanTypewriter-Bold", size: 28, relativeTo: .title))
                    .tracking(1)
                    .foregroundColor(Color(red: 0.16, green: 0.12, blue: 0.08))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5)
                    .lineLimit(2)
                    .padding(.horizontal, 16)
            }
            .frame(width: 220, height: 145)
            .opacity(cardOpacity)
            .offset(y: cardOffset)
            .scaleEffect(cardScale)
            .rotationEffect(.degrees(cardRotation))
        }
        .frame(width: 240, height: 165)
        .onChange(of: word) {
            cardOpacity = 0
            cardOffset = -20
            cardScale = 0.75
            cardRotation = -8
            withAnimation(.spring(response: 0.38, dampingFraction: 0.65)) {
                cardOpacity = 1
                cardOffset = 0
                cardScale = 1
                cardRotation = 0
            }
        }
        .onAppear {
            cardOpacity = 0
            cardOffset = -20
            cardScale = 0.75
            cardRotation = -8
            withAnimation(.spring(response: 0.38, dampingFraction: 0.65)) {
                cardOpacity = 1
                cardOffset = 0
                cardScale = 1
                cardRotation = 0
            }
        }
    }
}

// MARK: - PreviewCardView (intro screen decorative stack)

struct PreviewCardView: View {
    let word: String
    let rotation: Double
    let offsetX: CGFloat
    let offsetY: CGFloat
    let zIndex: Double

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.12), radius: 5, x: 2, y: 3)

            RoundedRectangle(cornerRadius: 7)
                .stroke(Color(white: 0.87), lineWidth: 1.5)

            Text(word)
                .font(.custom("AmericanTypewriter-Bold", size: 18, relativeTo: .title3))
                .foregroundColor(Color(red: 0.16, green: 0.12, blue: 0.08))
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .padding(.horizontal, 10)
        }
        .frame(width: 160, height: 100)
        .rotationEffect(.degrees(rotation))
        .offset(x: offsetX, y: offsetY)
        .zIndex(zIndex)
        // Each preview card is purely decorative — hidden from VoiceOver entirely.
        // The IntroView wraps the whole ZStack in a single accessibility element
        // that describes the stack as a group.
        .accessibilityHidden(true)
    }
}

#Preview {
    PlayingCardView(word: "COFFEE", isVisible: true)
}
