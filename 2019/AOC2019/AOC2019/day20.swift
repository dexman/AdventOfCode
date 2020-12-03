//
//  day20.swift
//  AOC2019
//
//  Created by Arthur Dexter on 12/20/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import AdventOfCodeUtils
import Foundation

func day20() throws {
    let tiles = try parseTiles(from: readInput())

    print(formatTiles(tiles))

    var portals: [String: Set<Position>] = [:]
    for (y, row) in tiles.enumerated() {
        for (x, tile) in row.enumerated() {
            if case let .portal(name, _, _) = tile {
                portals[name, default: []].insert(Position(x: x, y: y, level: 0))
            }
        }
    }

    print()
    for name in portals.keys.sorted() {
        print("\(name): \(portals[name, default: []])")
    }
    print()

    try part1(tiles)
    try part2(tiles)
}

private func part2(_ tiles: [[Tile]]) throws {
    let startPosition = try findPositions(of: .start, in: tiles).first.required()
    let endPosition = try findPositions(of: .end, in: tiles).first.required()
    let shortestPath = aStar(
        start: startPosition,
        goal: endPosition,
        distance: { _, _ in 1 },
        heuristicDistance: { _ in 0 },
        neighbors: { position in
            var neighbors: Set<Position> = Set([(0, -1), (0, 1), (-1, 0), (1, 0)].compactMap {
                let neighbor = position.addingToCoordinates($0)
                if
                    neighbor.y >= 0, neighbor.y < tiles.count,
                    neighbor.x >= 0, neighbor.x < tiles[neighbor.y].count,
                    tiles[neighbor.y][neighbor.x].isTraversable(at: position.level)
                {
                    return neighbor
                }
                return nil
            })
            if case let .portal(_, portalNeighbors, type) = tiles[position.y][position.x] {
                switch type {
                case .start, .end:
                    guard position.level == 0 else { fatalError("start/end are not traversable except on level 0") }
                case .inner:
                    neighbors.formUnion(portalNeighbors.map { $0.withLevel(position.level + 1) })
                case .outer:
                    if position.level > 0 {
                        neighbors.formUnion(portalNeighbors.map { $0.withLevel(position.level - 1) })
                    }
                }
            }
            return neighbors
        })

    let path = try (shortestPath?.dropFirst()).required()
    print("Day 20, part 02: Found a path of length \(path.count).")
}

private func part1(_ tiles: [[Tile]]) throws {
    let startPosition = try findPositions(of: .start, in: tiles).first.required()
    let endPosition = try findPositions(of: .end, in: tiles).first.required()
    let shortestPath = aStar(
        start: startPosition,
        goal: endPosition,
        distance: { _, _ in 1 },
        heuristicDistance: { _ in 0 },
        neighbors: { position in
            var neighbors: Set<Position> = Set([(0, -1), (0, 1), (-1, 0), (1, 0)].compactMap {
                let neighbor = position.addingToCoordinates($0)
                if
                    neighbor.y >= 0, neighbor.y < tiles.count,
                    neighbor.x >= 0, neighbor.x < tiles[neighbor.y].count,
                    tiles[neighbor.y][neighbor.x].isTraversable(at: position.level)
                {
                    return neighbor
                }
                return nil
            })
            if case let .portal(_, portalNeighbors, _) = tiles[position.y][position.x] {
                neighbors.formUnion(portalNeighbors)
            }
            return neighbors
        })

    let path = try (shortestPath?.dropFirst()).required()
    print("Day 20, part 01: Found a path of length \(path.count).")
}

private func findPositions(of type: PortalType, in tiles: [[Tile]]) -> Set<Position> {
    var found: Set<Position> = []
    for (y, row) in tiles.enumerated() {
        for (x, tile) in row.enumerated() {
            if case let .portal(_, _, theType) = tile, type == theType {
                found.insert(Position(x: x, y: y, level: 0))
            }
        }
    }
    return found
}

private func formatTiles(_ tiles: [[Tile]]) -> String {
    return tiles.map { row -> String in
        row.map { tile -> String in
            switch tile {
            case .passage:
                return "."
            case let .portal(name, _, _):
                return name
            case .empty:
                return " "
            case .wall:
                return "#"
            }
        }.joined()
    }.joined(separator: "\n")
}

private func parseTiles(from string: String) throws -> [[Tile]] {
    // 1st pass, whitespace fixup
    var lines: [String] = string.lines
    let maxLineLength = lines.map { $0.count }.max() ?? 0
    if maxLineLength > 0 {
        lines[0] = String(repeating: " ", count: maxLineLength - lines[0].count) + lines[0]
        lines[lines.count - 1] = lines[lines.count - 1] + String(repeating: " ", count: maxLineLength - lines[lines.count - 1].count)
    }
    guard lines.map({ $0.count }).max() == lines.map({ $0.count }).min() else { fatalError() }

    // 2nd pass, parse individual tiles.
    var portalLabels: [Position: Character] = [:]
    var tiles: [[Tile]] = try lines
        .enumerated()
        .map { (y, line) in
            try line.enumerated().map { (x, character) in
                switch character {
                case ".":
                    return .passage
                case "A"..."Z":
                    portalLabels[Position(x: x, y: y, level: 0)] = character
                    return .empty
                case " ":
                    return .empty
                case "#":
                    return .wall
                default:
                    throw ParseError<Tile>(String(character))
                }
            }
        }

    let mazeBoundsByRow: [Range<Int>?] = tiles.map { row in
        guard
            let startIndexX = row.firstIndex(where: { !$0.isEmpty }),
            let lastIndexX = row.lastIndex(where: { !$0.isEmpty })
        else {
            return nil
        }
        return startIndexX..<(lastIndexX + 1)
    }

    let mazeBoundsY: Range<Int>
    if
        let startIndexY = mazeBoundsByRow.firstIndex(where: { $0 != nil }),
        let lastIndexY = mazeBoundsByRow.lastIndex(where: { $0 != nil })
    {
        mazeBoundsY = startIndexY..<(lastIndexY + 1)
    } else {
        mazeBoundsY = 0..<0
    }

    let mazeBoundsX: Range<Int>
    if
        let startIndexX = mazeBoundsByRow.compactMap({ $0?.lowerBound }).min(),
        let endIndexX = mazeBoundsByRow.compactMap({ $0?.upperBound }).max()
    {
        mazeBoundsX = startIndexX..<endIndexX
    } else {
        mazeBoundsX = 0..<0
    }

    // 3rd pass, find portals.
    var portals: [String: Set<Position>] = [:]
    for y in 0..<tiles.count {
        for x in 0..<tiles[y].count {
            guard case .passage = tiles[y][x] else { continue }
            let currentPosition = Position(x: x, y: y, level: 0)
            let possibleLabelOffsets: [[(Int, Int)]] = [
                [(0, -2), (0, -1)],
                [(0, 1), (0, 2)],
                [(-2, 0), (-1, 0)],
                [(1, 0), (2, 0)],
            ]
            let label: String? = possibleLabelOffsets
                .compactMap { labelPositions in
                    let labelCharacters: [Character] = labelPositions.compactMap {
                        portalLabels[currentPosition.addingToCoordinates($0)]
                    }
                    guard labelCharacters.count == labelPositions.count else { return nil }
                    return String(labelCharacters)
                }
                .first
            if let label = label {
                portals[label, default: Set()].insert(Position(x: x, y: y, level: 0))
            }
        }
    }

    // 4th pass, replace passages with their portals

    let replacements: [String] = [
        "➀", "➁", "➂", "➃", "➄", "➅", "➆", "➇", "➈", "➉",
        "❶", "❷", "❸", "❹", "❺", "❻", "❼", "❽", "❾", "❿",
        "♠", "♥", "♦", "♣",
        "♚", "♛", "♜", "♝", "♞", "♟",
        "☀", "☁", "❆",
        "☺", "♨", "★", "✈", "✂", "✝", "♫", "✎", "☎", "✉",
    ]
    var replacementIndex = 0
    for label in portals.keys.sorted() {
        let connectedPositions = portals[label, default: []]
        let replacedLabel = replacements[replacementIndex]
        replacementIndex += 1
        for position in connectedPositions {
            let type: PortalType
            if label == "AA" {
                type = .start
            } else if label == "ZZ" {
                type = .end
            } else if
                position.x == mazeBoundsX.lowerBound || position.x == (mazeBoundsX.upperBound - 1) ||
                position.y == mazeBoundsY.lowerBound || position.y == (mazeBoundsY.upperBound - 1)
            {
                type = .outer
            } else {
                type = .inner
            }
            tiles[position.y][position.x] = .portal(replacedLabel, connectedPositions.subtracting([position]), type)
        }
    }

    return tiles
}

private struct Position: Hashable, CustomDebugStringConvertible {
    let x: Int
    let y: Int
    let level: Int

    var debugDescription: String {
        return "(\(x),\(y),\(level))"
    }

    func addingToCoordinates(_ offset: (x: Int, y: Int)) -> Position {
        return Position(x: x + offset.x, y: y + offset.y, level: level)
    }

    func withLevel(_ newLevel: Int) -> Position {
        guard newLevel >= 0 else { fatalError("Invalid level \(newLevel)")}
        return Position(x: x, y: y, level: newLevel)
    }
}

private enum Tile {
    case passage
    case portal(String, Set<Position>, PortalType)
    case empty
    case wall

    var isEmpty: Bool {
        switch self {
        case .empty:
            return true
        case .passage, .portal, .wall:
            return false
        }
    }

    func isTraversable(at level: Int) -> Bool {
        switch self {
        case .passage:
            return true
        case let .portal(_, _, type):
            switch type {
            case .start, .end:
                return level == 0
            case .inner:
                return true
            case .outer:
                return level != 0
            }
        case .empty, .wall:
            return false
        }
    }
}

private enum PortalType {
    case start
    case end
    case inner
    case outer
}
