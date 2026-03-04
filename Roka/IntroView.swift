import SwiftUI

struct IntroView: View {
    let onStart: () -> Void
    let onHowToPlay: () -> Void

    @State private var showHowToPlay = false
    @State private var appeared = false

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                // Left — preview cards
                ZStack {
                    PreviewCardView(word: "FREEDOM", rotation: -5,   offsetX: -6, offsetY:  6, zIndex: 1)
                    PreviewCardView(word: "BLORF",   rotation:  2.5, offsetX:  5, offsetY:  4, zIndex: 2)
                    PreviewCardView(word: "COFFEE",  rotation: -0.5, offsetX:  0, offsetY:  0, zIndex: 3)
                }
                .frame(maxWidth: .infinity)
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 0.88)
                .animation(.spring(response: 0.45, dampingFraction: 0.7).delay(0.1), value: appeared)

                Rectangle()
                    .fill(RokaColor.ink.opacity(0.08))
                    .frame(width: 1)
                    .padding(.vertical, 32)

                // Right — title + buttons
                VStack(spacing: 0) {
                    Spacer()

                    Text("Roka")
                        .font(.custom("AmericanTypewriter-Bold", size: 52, relativeTo: .largeTitle))
                        .tracking(12)
                        .foregroundColor(RokaColor.ink.opacity(0.82))
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : -10)
                        .animation(.easeOut(duration: 0.38), value: appeared)

                    Text("The word sorting game")
                        .font(.custom("AmericanTypewriter", size: 13, relativeTo: .caption))
                        .tracking(2)
                        .foregroundColor(RokaColor.inkLight)
                        .padding(.top, 5)
                        .padding(.bottom, 28)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : -6)
                        .animation(.easeOut(duration: 0.38).delay(0.07), value: appeared)

                    VStack(spacing: 10) {
                        RokaPrimaryButton(title: "Start Playing", action: onStart)
                        RokaSecondaryButton(title: "How to Play") {
                            withAnimation(.easeOut(duration: 0.22)) { showHowToPlay = true }
                        }
                    }
                    .frame(maxWidth: 220)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 8)
                    .animation(.easeOut(duration: 0.36).delay(0.16), value: appeared)

                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 36)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)

            if showHowToPlay {
                HowToPlaySheet(isPresented: $showHowToPlay)
                    .zIndex(10)
            }
        }
        .onAppear { appeared = true }
    }
}
