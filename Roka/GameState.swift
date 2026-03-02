import Foundation
import Combine

// MARK: - Level definition

enum GameLevel: Int, CaseIterable, Identifiable {
    case one   = 1
    case two   = 2
    case three = 3

    var id: Int { rawValue }

    var title: String { "LEVEL \(rawValue)" }

    /// Which categories are shown as answer buttons for this level
    var availableCategories: [WordCategory] {
        switch self {
        case .one:   return [.real, .notReal]
        case .two:   return [.real, .notReal, .abstract, .physical]
        case .three: return [.real, .notReal, .abstract, .physical]
        }
    }

    /// Level 3 uses a timed mode
    var isTimed: Bool { self == .three }
    var timePerCard: Double { 5.0 }
}

// MARK: - Supporting types

struct RoundResult {
    let word: String
    let correct: Bool
}

enum GamePhase {
    case playing
    case transitioning
    case finished
}

// MARK: - GameState

class GameState: ObservableObject {
    static let deckSize = 15

    @Published var level: GameLevel = .one
    @Published var deck: [Word]     = []
    @Published var currentIndex: Int = 0
    @Published var results: [RoundResult] = []
    @Published var phase: GamePhase = .playing
    @Published var lastFeedback: (text: String, correct: Bool)? = nil
    @Published var flashCategory: WordCategory? = nil

    // Level 3: timer
    @Published var timeRemaining: Double = 5.0
    private var timerTask: Task<Void, Never>? = nil

    var currentWord: Word? {
        guard currentIndex < deck.count else { return nil }
        return deck[currentIndex]
    }
    var score: Int   { results.filter(\.correct).count }
    var progress: String { "\(currentIndex + 1) / \(deck.count)" }

    func startGame(level: GameLevel) {
        self.level     = level
        deck           = Array(allWords.shuffled().prefix(GameState.deckSize))
        currentIndex   = 0
        results        = []
        phase          = .playing
        lastFeedback   = nil
        flashCategory  = nil
        if level.isTimed { startTimer() }
    }

    func guess(_ category: WordCategory) {
        guard phase == .playing, let word = currentWord else { return }
        timerTask?.cancel()

        let correct = word.accepts(category)
        results.append(RoundResult(word: word.text, correct: correct))
        flashCategory = category

        if correct {
            if word.categories.contains(.physical)  { lastFeedback = (text: "✓ \(word.text) is real & physical.", correct: true) }
            else if word.categories.contains(.abstract) { lastFeedback = (text: "✓ \(word.text) is real & abstract.", correct: true) }
            else { lastFeedback = (text: "✓ Correct!", correct: true) }
        } else {
            lastFeedback = (text: "✗ Not quite!", correct: false)
        }

        phase = .transitioning
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { [weak self] in
            self?.advance()
        }
    }

    private func advance() {
        flashCategory = nil
        lastFeedback  = nil
        currentIndex += 1
        if currentIndex >= deck.count {
            phase = .finished
        } else {
            phase = .playing
            if level.isTimed { startTimer() }
        }
    }

    // MARK: Timer (Level 3)

    private func startTimer() {
        timeRemaining = level.timePerCard
        timerTask?.cancel()
        timerTask = Task { @MainActor in
            let interval = 0.05
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
                guard !Task.isCancelled else { break }
                timeRemaining -= interval
                if timeRemaining <= 0 {
                    timeRemaining = 0
                    timeExpired()
                    break
                }
            }
        }
    }

    private func timeExpired() {
        guard phase == .playing else { return }
        // Count as wrong — no category tapped
        if let word = currentWord {
            results.append(RoundResult(word: word.text, correct: false))
        }
        RokaHaptic.wrong()
        lastFeedback = (text: "✗ Time's up!", correct: false)
        phase = .transitioning
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
            self?.advance()
        }
    }
}
