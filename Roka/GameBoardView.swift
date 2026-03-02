import SwiftUI

struct GameBoardView: View {
    @ObservedObject var gameState: GameState
    let level: GameLevel
    let onHome: () -> Void
    let onRestart: () -> Void
    let onLevels: () -> Void

    private func flashState(for cat: WordCategory) -> RokaCategoryButton.FlashState {
        guard let f = gameState.flashCategory, f == cat else { return .none }
        return (gameState.results.last?.correct == true) ? .correct : .wrong
    }

    var body: some View {
        ZStack {
            if gameState.phase == .finished {
                EndView(
                    results: gameState.results,
                    levelTitle: level.title,
                    onRestart: onRestart,
                    onHome: onHome,
                    onLevels: onLevels
                )
                .transition(.opacity)
            } else {
                GeometryReader { geo in
                    let w = geo.size.width
                    let h = geo.size.height

                    // ── Back button
                    RokaBackButton(action: onLevels)
                        .position(x: 36, y: 28)

                    // ── Level title top-center
                    Text(level.title)
                        .font(RokaFont.boldScaled(.title2, base: 20))
                        .tracking(4)
                        .foregroundColor(RokaColor.ink.opacity(0.82))
                        .position(x: w / 2, y: 28)

                    // ── Answer buttons — layout depends on level
                    switch level {
                    case .one:
                        Level1Buttons(
                            flashState: flashState,
                            guess: gameState.guess,
                            w: w, h: h
                        )
                    case .two, .three:
                        Level2And3Buttons(
                            flashState: flashState,
                            guess: gameState.guess,
                            w: w, h: h
                        )
                    }

                    // ── Center content
                    VStack(spacing: 10) {
                        Text(gameState.progress)
                            .font(RokaFont.regularScaled(.caption, base: 13))
                            .foregroundColor(RokaColor.inkFaint)
                            .tracking(1)

                        if let word = gameState.currentWord {
                            PlayingCardView(word: word.text, isVisible: true)
                                .id(gameState.currentIndex)
                        }

                        // Timer bar (Level 3 only)
                        if level.isTimed {
                            TimerBarView(progress: gameState.timeRemaining / level.timePerCard)
                                .frame(width: 180, height: 6)
                        }

                        // Feedback
                        ZStack {
                            if let fb = gameState.lastFeedback {
                                RokaFeedbackIcon(isCorrect: fb.correct)
                            } else {
                                Color.clear.frame(width: 28, height: 28)
                            }
                        }
                        .frame(height: 36)
                        .animation(.easeInOut(duration: 0.15), value: gameState.lastFeedback?.text)
                    }
                    .frame(width: w, height: h)
                    .allowsHitTesting(gameState.phase == .playing)
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: gameState.phase == .finished)
        // Haptics driven from GameState changes
        .onChange(of: gameState.lastFeedback?.correct) { _, newVal in
            guard let v = newVal else { return }
            if v { RokaHaptic.correct() } else { RokaHaptic.wrong() }
        }
    }
}

// MARK: - Level 1: REAL / NOT REAL — bottom-left and bottom-right

private struct Level1Buttons: View {
    let flashState: (WordCategory) -> RokaCategoryButton.FlashState
    let guess: (WordCategory) -> Void
    let w: CGFloat; let h: CGFloat

    private let hInset: CGFloat = 110
    private let vBottom: CGFloat = 46

    var body: some View {
        Group {
            RokaCategoryButton(title: "REAL",     flashState: flashState(.real))    { guess(.real) }
                .rotationEffect(.degrees(1.5))
                .position(x: hInset, y: h - vBottom)

            RokaCategoryButton(title: "NOT REAL", flashState: flashState(.notReal)) { guess(.notReal) }
                .rotationEffect(.degrees(-1.5))
                .position(x: w - hInset, y: h - vBottom)
        }
    }
}

// MARK: - Level 2 & 3: four corner buttons

private struct Level2And3Buttons: View {
    let flashState: (WordCategory) -> RokaCategoryButton.FlashState
    let guess: (WordCategory) -> Void
    let w: CGFloat; let h: CGFloat

    private let hInset: CGFloat = 110
    private let vTop:    CGFloat = 60
    private let vBottom: CGFloat = 46

    var body: some View {
        Group {
            RokaCategoryButton(title: "ABSTRACT", flashState: flashState(.abstract)) { guess(.abstract) }
                .rotationEffect(.degrees(-2))
                .position(x: hInset, y: vTop)

            RokaCategoryButton(title: "PHYSICAL", flashState: flashState(.physical)) { guess(.physical) }
                .rotationEffect(.degrees(2))
                .position(x: w - hInset, y: vTop)

            RokaCategoryButton(title: "REAL",     flashState: flashState(.real))     { guess(.real) }
                .rotationEffect(.degrees(1.5))
                .position(x: hInset, y: h - vBottom)

            RokaCategoryButton(title: "NOT REAL", flashState: flashState(.notReal))  { guess(.notReal) }
                .rotationEffect(.degrees(-1.5))
                .position(x: w - hInset, y: h - vBottom)
        }
    }
}

// MARK: - Timer Bar (Level 3)

struct TimerBarView: View {
    let progress: Double  // 1.0 → full, 0.0 → empty

    private var barColor: Color {
        if progress > 0.5 { return RokaColor.correct }
        if progress > 0.25 { return Color.orange }
        return RokaColor.wrong
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(RokaColor.ink.opacity(0.1))
                RoundedRectangle(cornerRadius: 3)
                    .fill(barColor)
                    .frame(width: geo.size.width * max(0, min(1, progress)))
                    .animation(.linear(duration: 0.05), value: progress)
            }
        }
        .accessibilityLabel("Time remaining: \(Int(progress * 100))%")
    }
}
