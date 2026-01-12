# MinesweeperMac (macOS, SwiftUI)

## Goal
Build a classic Minesweeper clone for macOS.

## Tech
- Swift 5+, SwiftUI
- Keep game logic UI-independent
- Use XCTest for core rules

## Project layout
- /Game: core logic (Board, Cell, Game state)
- /Views: SwiftUI views (ContentView, CellView)

## Rules
- First reveal must never hit a mine (and ideally avoid the 8 neighbors too)
- Flood fill reveals adjacent empty cells (adjacentMines == 0)
- Win when all non-mine cells are revealed

## Commands
- Build: xcodebuild -scheme MinesweeperMac -destination 'platform=macOS' build
- Test:  xcodebuild -scheme MinesweeperMac -destination 'platform=macOS' test
