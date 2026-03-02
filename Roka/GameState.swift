import Foundation
import Combine

struct RoundResult {
    let word: String
    let correct: Bool
}

enum GamePhase {
    case playing
    case transitioning
    case finished
}

enum GameLevel: Int, CaseIterable, Identifiable {
    case one = 1, two = 2, three = 3
    var id: Int { rawValue }
    var title: String { "LEVEL \(rawValue)" }
    var usesMultiSelect: Bool { self != .one }
    var isTimed: Bool { self == .three }
    var timePerCard: Double { 6.0 }
    var availableCategories: [WordCategory] {
        self == .one ? [.real, .notReal] : [.real, .notReal, .abstract, .physical]
    }
}

class GameState: ObservableObject {
    static let deckSize = 15

    @Published var level: GameLevel = .one
    @Published var deck: [Word] = []
    @Published var currentIndex: Int = 0
    @Published var results: [RoundResult] = []
    @Published var phase: GamePhase = .playing
    @Published var lastFeedback: (text: String, correct: Bool)? = nil

    // Multi-select state (L2/L3)
    @Published var selectedCategories: Set<WordCategory> = []

    // Flash: which categories to highlight after confirm
    @Published var flashCorrect: Set<WordCategory> = []
    @Published var flashWrong: Set<WordCategory> = []   // selected but wrong, or correct but missed
    @Published var shakingCategories: Set<WordCategory> = []

    // Timer (L3)
    @Published var timeRemaining: Double = 6.0
    private var timerTask: Task<Void, Never>?

    var currentWord: Word? {
        guard currentIndex < deck.count else { return nil }
        return deck[currentIndex]
    }
    var progress: String { "\(currentIndex + 1) / \(deck.count)" }

    // MARK: - Start

    func startGame(level: GameLevel) {
        self.level = level
        deck = Array(allWords.shuffled().prefix(GameState.deckSize))
        currentIndex = 0
        results = []
        phase = .playing
        lastFeedback = nil
        selectedCategories = []
        flashCorrect = []
        flashWrong = []
        shakingCategories = []
        if level.isTimed { startTimer() }
    }

    // MARK: - Level 1: single tap

    func guessSingle(_ category: WordCategory) {
        guard phase == .playing, let word = currentWord else { return }
        timerTask?.cancel()

        let correct = word.accepts(category)
        results.append(RoundResult(word: word.text, correct: correct))

        if correct {
            flashCorrect = [category]
            lastFeedback = feedbackText(word: word, correct: true)
        } else {
            flashWrong = [category]
            lastFeedback = (text: "✗ Not quite!", correct: false)
        }

        phase = .transitioning
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { [weak self] in
            self?.advance()
        }
    }

    // MARK: - Level 2/3: toggle + confirm

    func toggleCategory(_ category: WordCategory) {
        guard phase == .playing else { return }
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }

    func confirmSelection() {
        guard phase == .playing, let word = currentWord else { return }
        guard !selectedCategories.isEmpty else { return }
        timerTask?.cancel()

        let required = Set(word.categories)
        let correct = selectedCategories == required

        results.append(RoundResult(word: word.text, correct: correct))

        if correct {
            flashCorrect = selectedCategories
            lastFeedback = feedbackText(word: word, correct: true)
            phase = .transitioning
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { [weak self] in
                self?.advance()
            }
        } else {
            // Highlight which were wrong selected (red) and which were correct but missed (also red)
            let wrongSelected = selectedCategories.subtracting(required)
            let missed = required.subtracting(selectedCategories)
            flashWrong = wrongSelected.union(missed)
            shakingCategories = flashWrong
            lastFeedback = (text: "✗ Not quite!", correct: false)
            phase = .transitioning

            // Clear shake flag after animation completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { [weak self] in
                self?.shakingCategories = []
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) { [weak self] in
                self?.advance()
            }
        }
    }

    // MARK: - Helpers

    private func feedbackText(word: Word, correct: Bool) -> (text: String, correct: Bool) {
        if word.categories.contains(.physical) && word.categories.contains(.real) {
            return (text: "✓ \(word.text) is real & physical.", correct: true)
        } else if word.categories.contains(.abstract) && word.categories.contains(.real) {
            return (text: "✓ \(word.text) is real & abstract.", correct: true)
        }
        return (text: "✓ Correct!", correct: true)
    }

    private func advance() {
        selectedCategories = []
        flashCorrect = []
        flashWrong = []
        shakingCategories = []
        lastFeedback = nil
        currentIndex += 1
        if currentIndex >= deck.count {
            phase = .finished
        } else {
            phase = .playing
            if level.isTimed { startTimer() }
        }
    }

    // MARK: - Timer

    private func startTimer() {
        timeRemaining = level.timePerCard
        timerTask?.cancel()
        timerTask = Task { @MainActor in
            let tick = 0.05
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(tick * 1_000_000_000))
                guard !Task.isCancelled else { break }
                timeRemaining -= tick
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
        if let word = currentWord {
            let required = Set(word.categories)
            let missed = required.subtracting(selectedCategories)
            let wrongSelected = selectedCategories.subtracting(required)
            flashWrong = missed.union(wrongSelected)
            shakingCategories = flashWrong
        }
        results.append(RoundResult(word: currentWord?.text ?? "", correct: false))
        RokaHaptic.wrong()
        lastFeedback = (text: "✗ Time's up!", correct: false)
        phase = .transitioning
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { [weak self] in
            self?.shakingCategories = []
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.advance()
        }
    }
}
