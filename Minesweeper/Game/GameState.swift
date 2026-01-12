//
//  GameState.swift
//  Minesweeper
//
//  Created by Evgeny Plastinin on 12.01.2026.
//

import Combine
import Foundation

final class GameState: ObservableObject {
    enum Status: String {
        case playing
        case won
        case lost
    }

    @Published private(set) var board: Board
    @Published private(set) var status: Status = .playing
    @Published private(set) var elapsedSeconds: Int = 0
    @Published private(set) var currentDifficulty: Difficulty = .beginner
    @Published private(set) var hasStarted = false

    private var isFirstMove = true
    private var timer: Timer?

    init() {
        self.board = Board(rows: 1, cols: 1, mines: 0)
    }

    func newGame(difficulty: Difficulty? = nil) {
        let chosen = difficulty ?? currentDifficulty
        currentDifficulty = chosen
        board = Board(rows: chosen.rows, cols: chosen.cols, mines: chosen.mines)
        status = .playing
        isFirstMove = true
        elapsedSeconds = 0
        hasStarted = true
        stopTimer()
    }

    func reveal(row: Int, col: Int) {
        guard status == .playing else { return }
        guard row >= 0, row < board.rows, col >= 0, col < board.cols else { return }
        let startIndex = board.index(row: row, col: col)
        let startCell = board.cells[startIndex]
        if startCell.isFlagged || startCell.isRevealed {
            return
        }

        if isFirstMove {
            let exclusion = board.safeZoneIndices(row: row, col: col)
            board = Board(rows: board.rows, cols: board.cols, mines: board.mines, excludedIndices: exclusion)
            isFirstMove = false
            startTimerIfNeeded()
        }

        floodReveal(from: startIndex)
        updateStatusIfNeeded(revealedIndex: startIndex)
    }

    func toggleFlag(row: Int, col: Int) {
        guard status == .playing else { return }
        guard row >= 0, row < board.rows, col >= 0, col < board.cols else { return }
        let index = board.index(row: row, col: col)
        if board.cells[index].isRevealed {
            return
        }
        board.cells[index].isFlagged.toggle()
    }

    func chordReveal(row: Int, col: Int) {
        guard status == .playing else { return }
        guard row >= 0, row < board.rows, col >= 0, col < board.cols else { return }
        let index = board.index(row: row, col: col)
        let cell = board.cells[index]
        guard cell.isRevealed, !cell.isMine, cell.adjacentMines > 0 else { return }

        let neighborIndices = board.neighbors(of: index)
        let flaggedCount = neighborIndices.filter { board.cells[$0].isFlagged }.count
        guard flaggedCount == cell.adjacentMines else { return }

        for neighbor in neighborIndices {
            if board.cells[neighbor].isFlagged || board.cells[neighbor].isRevealed {
                continue
            }
            if board.cells[neighbor].isMine {
                board.cells[neighbor].isRevealed = true
                board.cells[neighbor].isExploded = true
                status = .lost
                revealAllMines()
                stopTimer()
                return
            }
            floodReveal(from: neighbor)
        }

        checkWinCondition()
    }

    private func updateStatusIfNeeded(revealedIndex: Int) {
        if board.cells[revealedIndex].isMine {
            status = .lost
            board.cells[revealedIndex].isExploded = true
            revealAllMines()
            stopTimer()
            return
        }

        checkWinCondition()
    }

    private func checkWinCondition() {
        let remainingSafe = board.cells.contains { cell in
            !cell.isMine && !cell.isRevealed
        }

        if !remainingSafe {
            status = .won
            revealAllMines()
            stopTimer()
        }
    }

    private func revealAllMines() {
        for index in board.cells.indices where board.cells[index].isMine {
            board.cells[index].isRevealed = true
        }
    }

    private func floodReveal(from startIndex: Int) {
        var queue: [Int] = [startIndex]
        var visited = Set<Int>()

        while let index = queue.first {
            queue.removeFirst()
            if visited.contains(index) { continue }
            visited.insert(index)

            if board.cells[index].isFlagged || board.cells[index].isRevealed {
                continue
            }

            board.cells[index].isRevealed = true

            if board.cells[index].isMine {
                continue
            }

            if board.cells[index].adjacentMines == 0 {
                for neighbor in board.neighbors(of: index) {
                    if !visited.contains(neighbor) {
                        queue.append(neighbor)
                    }
                }
            }
        }
    }

    private func startTimerIfNeeded() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            if self.status == .playing {
                self.elapsedSeconds += 1
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
