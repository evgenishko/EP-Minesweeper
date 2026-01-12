//
//  Difficulty.swift
//  Minesweeper
//
//  Created by Evgeny Plastinin on 12.01.2026.
//

import Foundation

enum Difficulty: String, CaseIterable, Identifiable {
    case beginner
    case intermediate
    case expert

    var id: String { rawValue }

    var title: String {
        switch self {
        case .beginner:
            return "Beginner"
        case .intermediate:
            return "Intermediate"
        case .expert:
            return "Expert"
        }
    }

    var rows: Int {
        switch self {
        case .beginner:
            return 10
        case .intermediate:
            return 20
        case .expert:
            return 50
        }
    }

    var cols: Int {
        switch self {
        case .beginner:
            return 10
        case .intermediate:
            return 20
        case .expert:
            return 30
        }
    }

    var mines: Int {
        switch self {
        case .beginner:
            return 10
        case .intermediate:
            return 80
        case .expert:
            return 450
        }
    }

    var summary: String {
        "\(rows)×\(cols) • \(mines) mines"
    }
}
