//
//  Board.swift
//  Minesweeper
//
//  Created by Evgeny Plastinin on 12.01.2026.
//

import Foundation

struct Board: Hashable {
    let rows: Int
    let cols: Int
    let mines: Int
    var cells: [Cell]

    init(rows: Int = 10, cols: Int = 10, mines: Int = 10, excludedIndices: Set<Int> = []) {
        let safeRows = max(1, rows)
        let safeCols = max(1, cols)
        let cellCount = safeRows * safeCols
        let availableCells = max(0, cellCount - excludedIndices.count)
        let safeMines = min(max(0, mines), availableCells)

        self.rows = safeRows
        self.cols = safeCols
        self.mines = safeMines
        self.cells = Board.makeCells(rows: safeRows, cols: safeCols, mines: safeMines, excludedIndices: excludedIndices)
    }

    func index(row: Int, col: Int) -> Int {
        row * cols + col
    }

    func neighbors(of index: Int) -> [Int] {
        let row = index / cols
        let col = index % cols
        var result: [Int] = []

        for r in max(0, row - 1)...min(rows - 1, row + 1) {
            for c in max(0, col - 1)...min(cols - 1, col + 1) {
                if r == row && c == col { continue }
                result.append(r * cols + c)
            }
        }

        return result
    }

    func safeZoneIndices(row: Int, col: Int) -> Set<Int> {
        let center = index(row: row, col: col)
        return Set([center] + neighbors(of: center))
    }

    private static func makeCells(rows: Int, cols: Int, mines: Int, excludedIndices: Set<Int>) -> [Cell] {
        let cellCount = rows * cols
        var mineSet = Set<Int>()
        let availableIndices = (0..<cellCount).filter { !excludedIndices.contains($0) }
        let shuffled = availableIndices.shuffled()
        for index in shuffled.prefix(mines) {
            mineSet.insert(index)
        }

        func adjacentMineCount(row: Int, col: Int) -> Int {
            var count = 0
            for r in max(0, row - 1)...min(rows - 1, row + 1) {
                for c in max(0, col - 1)...min(cols - 1, col + 1) {
                    if r == row && c == col { continue }
                    if mineSet.contains(r * cols + c) {
                        count += 1
                    }
                }
            }
            return count
        }

        var result: [Cell] = []
        result.reserveCapacity(cellCount)
        for row in 0..<rows {
            for col in 0..<cols {
                let index = row * cols + col
                let cell = Cell(
                    id: index,
                    row: row,
                    col: col,
                    isMine: mineSet.contains(index),
                    isRevealed: false,
                    isFlagged: false,
                    adjacentMines: adjacentMineCount(row: row, col: col),
                    isExploded: false
                )
                result.append(cell)
            }
        }
        return result
    }
}
