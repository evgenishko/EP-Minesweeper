//
//  ContentView.swift
//  Minesweeper
//
//  Created by Evgeny Plastinin on 12.01.2026.
//

import AppKit
import SwiftUI

struct ContentView: View {
    @StateObject private var game = GameState()
    @State private var selectedDifficulty: Difficulty = .beginner
    private let cellSize: CGFloat = 26
    private let spacing: CGFloat = 4
    private let boardPadding: CGFloat = 10
    private let contentPadding: CGFloat = 40
    private let glassPadding: CGFloat = 24

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.68, green: 0.88, blue: 0.98),
                    Color(red: 0.76, green: 0.93, blue: 0.86),
                    Color(red: 0.88, green: 0.84, blue: 0.98)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            RoundedRectangle(cornerRadius: 44)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 44)
                        .stroke(Color.white.opacity(0.45), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.12), radius: 24, x: 0, y: 12)
                .padding(24)

            VStack(spacing: 16) {
                VStack(spacing: 6) {
                    if game.hasStarted {
                        Text("\(game.board.rows) × \(game.board.cols) • mines: \(game.board.mines)")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text(statusText)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(statusColor)
                    } else {
                        Text("Choose your difficulty")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text("Pick a level to start the game.")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                }

                if !game.hasStarted {
                    difficultyPicker
                }

                HStack(spacing: 12) {
                    if game.hasStarted {
                        Button("New Game") {
                            game.newGame(difficulty: game.currentDifficulty)
                            resizeWindow(for: game.board, includePicker: false)
                        }
                        .keyboardShortcut("n", modifiers: [.command])
                        .buttonStyle(.borderedProminent)
                        .tint(Color(red: 0.25, green: 0.55, blue: 0.75))

                        Text("Flags: \(remainingFlags)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text("Time: \(formattedTime)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                if game.hasStarted {
                    ZStack {
                        BoardView(
                            board: game.board,
                            onReveal: { row, col in
                                game.reveal(row: row, col: col)
                            },
                            onChord: { row, col in
                                game.chordReveal(row: row, col: col)
                            },
                            onToggleFlag: { row, col in
                                game.toggleFlag(row: row, col: col)
                            }
                        )
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.white.opacity(0.35), lineWidth: 1)
                        )

                        if game.status != .playing {
                            statusOverlay
                        }
                    }
                }
            }
            .padding(contentPadding)
        }
        .onAppear {
            selectedDifficulty = game.currentDifficulty
        }
    }

    private var difficultyPicker: some View {
        HStack(spacing: 12) {
            ForEach(Difficulty.allCases) { difficulty in
                Button {
                    selectedDifficulty = difficulty
                    game.newGame(difficulty: difficulty)
                    resizeWindow(for: game.board, includePicker: false)
                } label: {
                    VStack(spacing: 4) {
                        Text(difficulty.title)
                            .font(.subheadline.weight(.semibold))
                        Text(difficulty.summary)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(selectedDifficulty == difficulty ? Color(red: 0.2, green: 0.5, blue: 0.7) : .gray)
            }
        }
        .padding(10)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.35), lineWidth: 1)
        )
    }

    private var statusText: String {
        switch game.status {
        case .playing:
            return "Playing"
        case .won:
            return "You won!"
        case .lost:
            return "Boom! You lost."
        }
    }

    private var statusColor: Color {
        switch game.status {
        case .playing:
            return .secondary
        case .won:
            return .green
        case .lost:
            return .red
        }
    }

    private var remainingFlags: Int {
        let used = game.board.cells.filter { $0.isFlagged }.count
        return max(0, game.board.mines - used)
    }

    private var formattedTime: String {
        let minutes = game.elapsedSeconds / 60
        let seconds = game.elapsedSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private var statusOverlay: some View {
        VStack(spacing: 8) {
            Text(statusText)
                .font(.title2.weight(.bold))
            Text("Press New Game to play again.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(statusColor.opacity(0.6), lineWidth: 2)
        )
    }

    private func resizeWindow(for board: Board, includePicker: Bool) {
        guard let window = NSApp.keyWindow ?? NSApp.windows.first else { return }
        let gridWidth = CGFloat(board.cols) * cellSize + CGFloat(max(0, board.cols - 1)) * spacing
        let gridHeight = CGFloat(board.rows) * cellSize + CGFloat(max(0, board.rows - 1)) * spacing
        let boardBlockWidth = gridWidth + boardPadding * 2
        let boardBlockHeight = gridHeight + boardPadding * 2
        let headerHeight: CGFloat = includePicker ? 160 : 120
        let controlsHeight: CGFloat = includePicker ? 0 : 44
        let verticalSpacing: CGFloat = includePicker ? 32 : 24
        let contentHeight = headerHeight + controlsHeight + verticalSpacing + boardBlockHeight + contentPadding * 2
        let contentWidth = boardBlockWidth + contentPadding * 2
        let finalWidth = contentWidth + glassPadding * 2
        let finalHeight = contentHeight + glassPadding * 2

        window.setContentSize(NSSize(width: finalWidth, height: finalHeight))
    }
}

#Preview {
    ContentView()
}
