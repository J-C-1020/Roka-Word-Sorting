//
//  LevelMenuView.swift
//  Roka
//
//  Created by Yolanda Cantu on 02/03/26.
//

import SwiftUI

struct LevelMenuView: View {
    let onSelect: (GameLevel) -> Void
    let onBack: () -> Void

    @State private var appeared = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                Spacer()

                Text("LEVELS")
                    .font(RokaFont.boldScaled(.largeTitle, base: 40))
                    .tracking(10)
                    .foregroundColor(RokaColor.ink.opacity(0.82))
                    .padding(.bottom, 36)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : -10)
                    .animation(.easeOut(duration: 0.35), value: appeared)

                HStack(spacing: 24) {
                    ForEach(GameLevel.allCases) { level in
                        RokaLevelButton(number: level.rawValue, isUnlocked: true) {
                            onSelect(level)
                        }
                        .opacity(appeared ? 1 : 0)
                        .scaleEffect(appeared ? 1 : 0.85)
                        .animation(
                            .spring(response: 0.4, dampingFraction: 0.65)
                            .delay(Double(level.rawValue - 1) * 0.07),
                            value: appeared
                        )
                    }
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Back button top-left
            RokaBackButton(action: onBack)
                .padding(.top, 16)
                .padding(.leading, 20)
        }
        .onAppear { appeared = true }
    }
}
