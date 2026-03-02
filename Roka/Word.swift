import Foundation

enum WordCategory: String, CaseIterable {
    case real     = "REAL"
    case notReal  = "NOT REAL"
    case physical = "PHYSICAL"
    case abstract = "ABSTRACT"
}

struct Word: Identifiable {
    let id = UUID()
    let text: String
    let categories: [WordCategory]

    func accepts(_ guess: WordCategory) -> Bool {
        categories.contains(guess)
    }
}

let allWords: [Word] = [
    // Real + Physical
    Word(text: "COFFEE",    categories: [.real, .physical]),
    Word(text: "MOUNTAIN",  categories: [.real, .physical]),
    Word(text: "APPLE",     categories: [.real, .physical]),
    Word(text: "BRIDGE",    categories: [.real, .physical]),
    Word(text: "STONE",     categories: [.real, .physical]),
    Word(text: "PENCIL",    categories: [.real, .physical]),
    Word(text: "CANDLE",    categories: [.real, .physical]),
    Word(text: "WINDOW",    categories: [.real, .physical]),
    Word(text: "FEATHER",   categories: [.real, .physical]),
    Word(text: "LADDER",    categories: [.real, .physical]),

    // Real + Abstract
    Word(text: "HAPPINESS", categories: [.real, .abstract]),
    Word(text: "FREEDOM",   categories: [.real, .abstract]),
    Word(text: "JUSTICE",   categories: [.real, .abstract]),
    Word(text: "COURAGE",   categories: [.real, .abstract]),
    Word(text: "MEMORY",    categories: [.real, .abstract]),
    Word(text: "ENVY",      categories: [.real, .abstract]),
    Word(text: "WISDOM",    categories: [.real, .abstract]),
    Word(text: "TRUTH",     categories: [.real, .abstract]),

    // Not Real (Roka)
    Word(text: "BLORF",   categories: [.notReal]),
    Word(text: "STIVEN",  categories: [.notReal]),
    Word(text: "MOKA",    categories: [.notReal]),
    Word(text: "TRILU",   categories: [.notReal]),
    Word(text: "WAVEN",   categories: [.notReal]),
    Word(text: "PROKE",   categories: [.notReal]),
    Word(text: "DRIMPLE", categories: [.notReal]),
    Word(text: "FLURB",   categories: [.notReal]),
    Word(text: "ZORBIK",  categories: [.notReal]),
    Word(text: "VRANT",   categories: [.notReal]),
    Word(text: "GRULF",   categories: [.notReal]),
    Word(text: "SNARK",   categories: [.notReal]),
]
