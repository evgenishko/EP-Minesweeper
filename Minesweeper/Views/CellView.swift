//
//  CellView.swift
//  Minesweeper
//
//  Created by Evgeny Plastinin on 12.01.2026.
//

import SwiftUI

struct CellView: View {
    let cell: Cell
    let size: CGFloat
    private let numberColors: [Int: Color] = [
        1: .blue,
        2: .green,
        3: .red,
        4: .indigo,
        5: .brown,
        6: .teal,
        7: .black,
        8: .gray
    ]

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(backgroundFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(borderColor, lineWidth: cell.isRevealed ? 1 : 1.5)
                )
                .shadow(color: shadowColor, radius: cell.isRevealed ? 0 : 2, x: 0, y: 1)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.ultraThinMaterial.opacity(cell.isRevealed ? 0.0 : 0.45))
                )

            if cell.isRevealed && cell.isMine {
                Text(cell.isExploded ? "💥" : "💣")
                    .font(.system(size: size * 0.6))
            }

            if cell.isFlagged && !cell.isRevealed {
                Image(systemName: "flag.fill")
                    .font(.system(size: size * 0.5, weight: .bold))
                    .foregroundStyle(.orange)
            } else if cell.isRevealed && !cell.isMine && cell.adjacentMines > 0 {
                Text("\(cell.adjacentMines)")
                    .font(.system(size: size * 0.5, weight: .bold, design: .rounded))
                    .foregroundStyle(numberColors[cell.adjacentMines] ?? .primary)
            }
        }
        .frame(width: size, height: size)
    }

    private var backgroundFill: some ShapeStyle {
        if cell.isRevealed {
            return LinearGradient(
                colors: [
                    Color(nsColor: .controlBackgroundColor),
                    Color(nsColor: .windowBackgroundColor)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        return LinearGradient(
            colors: [
                Color.white.opacity(0.7),
                Color(nsColor: .controlBackgroundColor).opacity(0.6)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var borderColor: Color {
        cell.isRevealed ? Color.gray.opacity(0.4) : Color.white.opacity(0.8)
    }

    private var shadowColor: Color {
        Color.black.opacity(cell.isRevealed ? 0 : 0.2)
    }
}

#Preview {
    CellView(
        cell: Cell(
            id: 0,
            row: 0,
            col: 0,
            isMine: true,
            isRevealed: true,
            isFlagged: false,
            adjacentMines: 0,
            isExploded: false
        ),
        size: 24
    )
        .padding()
}
