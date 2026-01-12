//
//  CellInteractionView.swift
//  Minesweeper
//
//  Created by Evgeny Plastinin on 12.01.2026.
//

import AppKit
import SwiftUI

struct CellInteractionView: NSViewRepresentable {
    let cell: Cell
    let size: CGFloat
    let onReveal: (Int, Int) -> Void
    let onChord: (Int, Int) -> Void
    let onToggleFlag: (Int, Int) -> Void

    func makeNSView(context: Context) -> InteractiveCellHostingView {
        let view = InteractiveCellHostingView(rootView: CellView(cell: cell, size: size))
        view.onLeftClick = { onReveal(cell.row, cell.col) }
        view.onDoubleClick = { onChord(cell.row, cell.col) }
        view.onRightClick = { onToggleFlag(cell.row, cell.col) }
        view.frame = CGRect(origin: .zero, size: CGSize(width: size, height: size))
        return view
    }

    func updateNSView(_ nsView: InteractiveCellHostingView, context: Context) {
        nsView.rootView = CellView(cell: cell, size: size)
        nsView.onLeftClick = { onReveal(cell.row, cell.col) }
        nsView.onDoubleClick = { onChord(cell.row, cell.col) }
        nsView.onRightClick = { onToggleFlag(cell.row, cell.col) }
        nsView.frame = CGRect(origin: .zero, size: CGSize(width: size, height: size))
    }
}

final class InteractiveCellHostingView: NSHostingView<CellView> {
    var onLeftClick: (() -> Void)?
    var onDoubleClick: (() -> Void)?
    var onRightClick: (() -> Void)?

    override func mouseDown(with event: NSEvent) {
        if event.clickCount == 2 {
            onDoubleClick?()
        } else {
            onLeftClick?()
        }
    }

    override func rightMouseDown(with event: NSEvent) {
        onRightClick?()
    }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        true
    }
}
