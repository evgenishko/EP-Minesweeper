//
//  Cell.swift
//  Minesweeper
//
//  Created by Evgeny Plastinin on 12.01.2026.
//

import Foundation

struct Cell: Identifiable, Hashable {
    let id: Int
    let row: Int
    let col: Int
    let isMine: Bool
    var isRevealed: Bool
    var isFlagged: Bool
    var adjacentMines: Int
    var isExploded: Bool
}
