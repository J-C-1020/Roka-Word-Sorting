import SwiftUI

struct GameBoardView: View {
    @ObservedObject var gameState: GameState
    let level: GameLevel
    let onHome: () -> Void
    let onRestart: () -> Void
    let onLevels: () -> Void

    @State private var showIntro = true
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @ScaledMetric(relativeTo: .title2)  private var levelTitleSize: CGFloat = 20
    @ScaledMetric(relativeTo: .caption) private var progressSize:   CGFloat = 13

    /// Scroll only when Dynamic Type is large enough to risk overflow
    private var needsScroll: Bool {
        dynamicTypeSize >= .xLarge
    }

    private func flashFor(_ cat: WordCategory) -> RokaCategoryFlash {
        if gameState.flashCorrect.contains(cat) { return .correct }
        if gameState.flashWrong.contains(cat)   { return .wrong }
        return .none
    }

    var body: some View {
        ZStack {
            if gameState.phase == .finished {
                EndView(
                    results: gameState.results,
                    levelTitle: level.title,
                    onRestart: {
                        showIntro = true
                        onRestart()
                    },
                    onHome: onHome,
                    onLevels: onLevels
                )
                .transition(.opacity)

            } else if gameState.phase != .waiting {
                VStack(spacing: 0) {

                    // ── Top bar ──────────────────────────────────────────────
                    HStack {
                        RokaBackButton(action: onLevels)
                        Spacer()
                        Text(level.title)
                            .font(.custom("AmericanTypewriter-Bold",
                                          size: min(levelTitleSize, 22)))
                            .tracking(4)
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                            .foregroundColor(RokaColor.ink.opacity(0.82))
                        Spacer()
                        Color.clear.frame(width: 36, height: 36)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 6)

                    // ── Top category buttons (L2 / L3 only) ─────────────────
                    if level != .one {
                        HStack {
                            categoryButton(for: .abstract, rotation: -2)
                            Spacer()
                            categoryButton(for: .physical, rotation: 2)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 6)
                    }

                    // ── Centre: plain VStack or ScrollView by Dynamic Type ───
                    centerContent
                        .allowsHitTesting(gameState.phase == .playing)

                    // ── Bottom row: REAL / CONFIRM / NOT REAL ────────────────
                    HStack(alignment: .center) {
                        if level == .one {
                            categoryButton(for: .real,    rotation:  1.5, singleTap: true)
                            Spacer()
                            categoryButton(for: .notReal, rotation: -1.5, singleTap: true)
                        } else {
                            categoryButton(for: .real,    rotation:  1.5)
                            Spacer()
                            if !gameState.selectedCategories.isEmpty
                                && gameState.phase == .playing {
                                RokaConfirmButton {
                                    RokaHaptic.tap()
                                    gameState.confirmSelection()
                                }
                                .transition(.scale(scale: 0.7).combined(with: .opacity))
                            }
                            Spacer()
                            categoryButton(for: .notReal, rotation: -1.5)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 6)
                    .padding(.bottom, 12)
                    .animation(.spring(response: 0.3, dampingFraction: 0.65),
                               value: gameState.selectedCategories.isEmpty)
                }
                .transition(.opacity)
            }

            if showIntro {
                LevelIntroOverlay()
                    .transition(.opacity)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                            withAnimation(.easeInOut(duration: 0.55)) {
                                showIntro = false
                            }
                            gameState.beginPlaying()
                        }
                    }
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.65),
                   value: !gameState.selectedCategories.isEmpty && gameState.phase == .playing)
        .animation(.easeInOut(duration: 0.25), value: gameState.phase == .finished)
        .onChange(of: gameState.lastFeedback?.correct) { _, newVal in
            guard let v = newVal else { return }
            if v { RokaHaptic.correct() } else { RokaHaptic.wrong() }
        }
    }

    // ── Centre content ───────────────────────────────────────────────────────
    /// Extracted so the ScrollView/VStack swap stays in one place.
    @ViewBuilder
    private var centerContent: some View {
        let inner = centreStack
        if needsScroll {
            ScrollView(.vertical, showsIndicators: false) {
                inner
            }
        } else {
            inner
                .frame(maxHeight: .infinity)
        }
    }

    /// The actual progress + card + timer + feedback stack.
    private var centreStack: some View {
        VStack(spacing: 8) {
            Text(gameState.progress)
                .font(.custom("AmericanTypewriter",
                              size: min(progressSize, 14)))
                .foregroundColor(RokaColor.inkLight)
                .tracking(1)

            if let word = gameState.currentWord {
                PlayingCardView(word: word.text, isVisible: true)
                    .id(gameState.currentIndex)
            }

            if level.isTimed {
                TimerBarView(
                    progress: gameState.timeRemaining / level.timePerCard
                )
                .frame(width: 180, height: 6)
                .padding(.top, 2)
            }

            ZStack {
                if let fb = gameState.lastFeedback {
                    RokaFeedbackIcon(isCorrect: fb.correct)
                } else {
                    Color.clear.frame(width: 28, height: 28)
                }
            }
            .frame(height: 32)
            .animation(.easeInOut(duration: 0.15),
                       value: gameState.lastFeedback?.text)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
    }

    // ── Extracted category button builder ────────────────────────────────────
    @ViewBuilder
    private func categoryButton(
        for cat: WordCategory,
        rotation: Double,
        singleTap: Bool = false
    ) -> some View {
        RokaCategoryButton(
            title: cat.rawValue,
            isSelected: gameState.selectedCategories.contains(cat),
            flashState: flashFor(cat),
            isShaking: gameState.shakingCategories.contains(cat)
        ) {
            guard gameState.phase == .playing else { return }
            if singleTap {
                RokaHaptic.tap()
                gameState.guessSingle(cat)
            } else {
                RokaHaptic.toggle()
                gameState.toggleCategory(cat)
            }
        }
        .rotationEffect(.degrees(rotation))
    }
}

// MARK: - Intro overlay

private struct LevelIntroOverlay: View {
    @ScaledMetric(relativeTo: .title2) private var textSize: CGFloat = 28

    var body: some View {
        ZStack {
            PaperBackground().ignoresSafeArea()

            Text("Select all categories\nthat apply")
                .font(.custom("AmericanTypewriter-Bold",
                              size: min(textSize, 32)))
                .tracking(1)
                .multilineTextAlignment(.center)
                .foregroundColor(RokaColor.ink)
        }
    }
}
