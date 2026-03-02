//
//  ContentView.swift
//  ROKA
//
//  Created by Eleonora Persico on 25/02/26.
//

import SwiftUI

enum AppScreen {
    case intro
    case levels
    case game(GameLevel)
}

struct ContentView: View {
    @StateObject private var gameState = GameState()
    @State private var screen: AppScreen = .intro

    var body: some View {
        ZStack {
            PaperBackground().ignoresSafeArea()

            switch screen {
            case .intro:
                IntroView(
                    onStart:     { withAnimation(.easeInOut(duration: 0.3)) { screen = .levels } },
                    onHowToPlay: { /* sheet handled inside IntroView */ }
                )
                .transition(.opacity)

            case .levels:
                LevelMenuView(
                    onSelect: { level in
                        gameState.startGame(level: level)
                        withAnimation(.easeInOut(duration: 0.3)) { screen = .game(level) }
                    },
                    onBack: { withAnimation(.easeInOut(duration: 0.3)) { screen = .intro } }
                )
                .transition(.opacity)

            case .game(let level):
                GameBoardView(
                    gameState: gameState,
                    level: level,
                    onHome: { withAnimation(.easeInOut(duration: 0.3)) { screen = .intro } },
                    onRestart: {
                        gameState.startGame(level: level)
                    },
                    onLevels: { withAnimation(.easeInOut(duration: 0.3)) { screen = .levels } }
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: {
            if case .intro = screen { return 0 }
            if case .levels = screen { return 1 }
            return 2
        }())
    }
}


#Preview{
    ContentView()
}
