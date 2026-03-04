import SwiftUI

struct GameBoardView: View {
    @ObservedObject var gameState: GameState
    let level: GameLevel
    let onHome: () -> Void
    let onRestart: () -> Void
    let onLevels: () -> Void
    
    @State private var showIntro = true

    // Flash state per category
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
                GeometryReader { geo in
                    let w = geo.size.width
                    let h = geo.size.height

                    // Back button
                    RokaBackButton(action: onLevels)
                        .position(x: 36, y: 28)

                    // Level title
                    Text(level.title)
                        .font(RokaFont.boldScaled(.title2, base: 20))
                        .tracking(4)
                        .foregroundColor(RokaColor.ink.opacity(0.82))
                        .position(x: w / 2, y: 28)

                    // Answer buttons
                    if level == .one {
                        // ── Level 1: single-tap, bottom corners only
                        ForEach([WordCategory.real, .notReal], id: \.self) { cat in
                            let isLeft = cat == .real
                            RokaCategoryButton(
                                title: cat.rawValue,
                                isSelected: false,
                                flashState: flashFor(cat),
                                isShaking: gameState.shakingCategories.contains(cat)
                            ) {
                                RokaHaptic.tap()
                                gameState.guessSingle(cat)
                            }
                            .rotationEffect(.degrees(isLeft ? 1.5 : -1.5))
                            .position(x: isLeft ? 110 : w - 110, y: h - 46)
                        }

                    } else {
                        // ── Level 2 & 3: four corners, toggleable
                        let corners: [(cat: WordCategory, x: CGFloat, y: CGFloat, rot: Double)] = [
                            (.abstract, 110,       60,     -2.0),
                            (.physical, w - 110,   60,      2.0),
                            (.real,     110,     h - 46,    1.5),
                            (.notReal,  w - 110, h - 46,   -1.5),
                        ]
                        ForEach(corners, id: \.cat) { item in
                            RokaCategoryButton(
                                title: item.cat.rawValue,
                                isSelected: gameState.selectedCategories.contains(item.cat),
                                flashState: flashFor(item.cat),
                                isShaking: gameState.shakingCategories.contains(item.cat)
                            ) {
                                guard gameState.phase == .playing else { return }
                                RokaHaptic.toggle()
                                gameState.toggleCategory(item.cat)
                            }
                            .rotationEffect(.degrees(item.rot))
                            .position(x: item.x, y: item.y)
                        }

                        // Confirm button — appears once ≥1 selected
                        if !gameState.selectedCategories.isEmpty && gameState.phase == .playing {
                            RokaConfirmButton {
                                RokaHaptic.tap()
                                gameState.confirmSelection()
                            }
                            .position(x: w / 2, y: h - 46)
                            .animation(.spring(response: 0.3, dampingFraction: 0.65),
                                       value: gameState.selectedCategories.isEmpty)
                        }
                    }

                    // ── Centre content
                    VStack(spacing: 10) {
                        Text(gameState.progress)
                            .font(RokaFont.regularScaled(.caption, base: 13))
                            .foregroundColor(RokaColor.inkLight)
                            .tracking(1)

                        if let word = gameState.currentWord {
                            PlayingCardView(word: word.text, isVisible: true)
                                .id(gameState.currentIndex)
                        }

                        // Timer bar (Level 3 only)
                        if level.isTimed {
                            TimerBarView(
                                progress: gameState.timeRemaining / level.timePerCard
                            )
                            .frame(width: 180, height: 6)
                            .padding(.top, 4)
                        }

                        // Feedback icon
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
        .animation(.easeInOut(duration: 0.25), value: gameState.phase == .finished)
        .onChange(of: gameState.lastFeedback?.correct) { _, newVal in
            guard let v = newVal else { return }
            if v { RokaHaptic.correct() } else { RokaHaptic.wrong() }
        }
    }
}

private struct LevelIntroOverlay: View {
    
    var body: some View {
        ZStack {
            // Same paper background — seamless, no jarring colour shift
            PaperBackground().ignoresSafeArea()
            
            Text("Select all categories\nthat apply")
                .font(.custom("AmericanTypewriter-Bold", size: 28, relativeTo: .title2))
                .tracking(1)
                .multilineTextAlignment(.center)
                .foregroundColor(RokaColor.ink)
        }
    }
}

