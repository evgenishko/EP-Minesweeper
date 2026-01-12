//
//  BoardView.swift
//  Minesweeper
//
//  Created by Evgeny Plastinin on 12.01.2026.
//

import SwiftUI

struct BoardView: View {
    let board: Board
    let onReveal: (Int, Int) -> Void
    let onChord: (Int, Int) -> Void
    let onToggleFlag: (Int, Int) -> Void

    private let cellSize: CGFloat = 26
    private let spacing: CGFloat = 4

    var body: some View {
        let columns = Array(repeating: GridItem(.fixed(cellSize), spacing: spacing), count: board.cols)
        LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(board.cells) { cell in
                CellInteractionView(
                    cell: cell,
                    size: cellSize,
                    onReveal: onReveal,
                    onChord: onChord,
                    onToggleFlag: onToggleFlag
                )
            }
        }
        .padding(spacing)
    }
}

#Preview {
    BoardView(
        board: Board(),
        onReveal: { _, _ in },
        onChord: { _, _ in },
        onToggleFlag: { _, _ in }
    )
        .padding()
}
