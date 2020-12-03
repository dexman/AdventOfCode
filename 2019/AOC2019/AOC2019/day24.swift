//
//  day24.swift
//  AOC2019
//
//  Created by Arthur Dexter on 12/24/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import AdventOfCodeUtils
import Foundation

func day24() throws {
    let initialTiles: [Int: [[Tile]]] = [0: try parseTiles(from: readInput())]
    part1(initialTiles)
    part2(initialTiles)
}

private func part2(_ initialTiles: [Int: [[Tile]]]) {
    var tiles = initialTiles
    var minutes = 0
    while minutes < 200 {
        tiles = step(tiles) { position in
            let sameLevelAdjacent = [
                (0, -1),
                (0, 1),
                (-1, 0),
                (1, 0),
            ].map { (offset: (x: Int, y: Int)) -> Position in
                Position(x: position.x + offset.x, y: position.y + offset.y, z: position.z)
            }.filter { position in
                position.x != 2 || position.y != 2
            }

            var lowerLevelAdjacent: [Position] = []
            if position.x == 0 { // left edge
                lowerLevelAdjacent.append(Position(x: 1, y: 2, z: position.z - 1))
            }
            if position.x == 4 { // right edge
                lowerLevelAdjacent.append(Position(x: 3, y: 2, z: position.z - 1))
            }
            if position.y == 0 { // top edge
                lowerLevelAdjacent.append(Position(x: 2, y: 1, z: position.z - 1))
            }
            if position.y == 4 { // bottom edge
                lowerLevelAdjacent.append(Position(x: 2, y: 3, z: position.z - 1))
            }

            var upperLevelAdjacent: [Position] = []
            if position.x == 1, position.y == 2 { // left inner edge
                upperLevelAdjacent.append(contentsOf: (0..<5).map { y in
                    Position(x: 0, y: y, z: position.z + 1)
                })
            } else if position.x == 3, position.y == 2 { // right inner edge
                upperLevelAdjacent.append(contentsOf: (0..<5).map { y in
                    Position(x: 4, y: y, z: position.z + 1)
                })
            } else if position.x == 2, position.y == 1 { // top inner edge
                upperLevelAdjacent.append(contentsOf: (0..<5).map { x in
                    Position(x: x, y: 0, z: position.z + 1)
                })
            } else if position.x == 2, position.y == 3 { // bottom inner edge
                upperLevelAdjacent.append(contentsOf: (0..<5).map { x in
                    Position(x: x, y: 4, z: position.z + 1)
                })
            }

            return sameLevelAdjacent + lowerLevelAdjacent + upperLevelAdjacent
        }
        minutes += 1
    }

    let totalNumberOfBugs: Int = tiles.values.map { $0.bugCount }.reduce(0, +)
    print("Day 24, part 02: After \(minutes) minutes, got \(totalNumberOfBugs) bugs.")
}

private func part1(_ initialTiles: [Int: [[Tile]]]) {
    var tiles = initialTiles
    var seen: Set<[Int: [[Tile]]]> = []
    var minutes = 0
    while seen.insert(tiles).inserted {
        tiles = step(tiles) { position in
            [
                (0, -1),
                (0, 1),
                (-1, 0),
                (1, 0),
            ].map { (offset: (x: Int, y: Int)) -> Position in
                Position(x: position.x + offset.x, y: position.y + offset.y, z: position.z)
            }
        }
        minutes += 1
    }

    let rating = biodiversityRating(of: tiles[0]!)
    print("Day 24, part 01: After \(minutes) minutes, got rating of \(rating)")
}

private func step(_ oldTiles: [Int: [[Tile]]], adjacent: (Position) -> [Position]) -> [Int: [[Tile]]] {
    let lowestLevel = oldTiles.keys.min() ?? 0
    let lowestLevelBugCount = oldTiles[lowestLevel]?.bugCount ?? 0
    let highestLevel = oldTiles.keys.max() ?? 0
    let highestLevelBugCount = oldTiles[highestLevel]?.bugCount ?? 0

    var tiles = oldTiles
    if lowestLevelBugCount > 0 {
        tiles[lowestLevel - 1] = Array(repeating: Array(repeating: .empty, count: 5), count: 5)
    }
    if highestLevelBugCount > 0 {
        tiles[highestLevel + 1] = Array(repeating: Array(repeating: .empty, count: 5), count: 5)
    }

    let adjacentCounts: [Int: [[Int]]] = Dictionary(uniqueKeysWithValues: tiles.map { (z, grid) in
        let gridAdjacentCounts: [[Int]] = grid.enumerated().map { (y, row) in
            row.enumerated().map { (x, tile) in
                adjacent(Position(x: x, y: y, z: z))
                    .compactMap { adjacentPosition in
                        tiles[adjacentPosition]
                    }
                    .filter { adjacentTlie in
                        adjacentTlie == .bug
                    }
                    .count
            }
        }
        return (z, gridAdjacentCounts)
    })

    return Dictionary(uniqueKeysWithValues: tiles.map { (z, grid) in
        let newGrid: [[Tile]] = grid.enumerated().map { (y, row) -> [Tile] in
            row.enumerated().map { (x, tile) -> Tile in
                let adjacentCount: Int =  adjacentCounts[z]?[y][x] ?? 0
                switch tile {
                case .bug:
                    if adjacentCount == 1 {
                        return .bug
                    } else {
                        return .empty
                    }
                case .empty:
                    if (1...2) ~= adjacentCount {
                        return .bug
                    } else {
                        return .empty
                    }
                }
            }
        }
        return (z, newGrid)
    })
}

private func biodiversityRating(of tiles: [[Tile]]) -> Int {
    let width = tiles.first?.count ?? 0
    let ratings: Decimal = tiles
        .enumerated()
        .flatMap { (y, row) -> [Decimal] in
            row.enumerated().map { x, tile -> Decimal in
                if tile == .bug {
                    return pow(2, y * width + x)
                } else {
                    return 0
                }
            }
        }
        .reduce(0, +)
    return (ratings as NSDecimalNumber).intValue
}

private extension Dictionary where Key == Int, Value == [[Tile]] {

    subscript(position: Position) -> Tile? {
        get {
            guard
                let grid = self[position.z],
                position.y >= 0, position.y < grid.count,
                position.x >= 0, position.x < grid[position.y].count
            else {
                return nil
            }
            return grid[position.y][position.x]
        }
    }
}

extension Array where Element == [Tile] {

    var bugCount: Int {
        enumerated().map { (y, row) -> Int in
            row.enumerated().filter { (x, tile) -> Bool in
                (y != 2 || x != 2) && tile == .bug
            }.count
        }
        .reduce(0, +)
    }
}

private func format(_ tiles: [Int: [[Tile]]]) -> String {
    return tiles.keys.sorted().compactMap { level in
        guard let grid = tiles[level] else { return nil }
        let gridString = grid.enumerated().map { (y, row) in
            row.enumerated().map { (x, tile) in
                guard x != 2 || y != 2 else { return "?" }
                switch tile {
                case .bug:
                    return "#"
                case .empty:
                    return "."
                }
            }.joined()
        }.joined(separator: "\n")

        return "Depth \(level):\n\(gridString)"
    }.joined(separator: "\n\n")
}

private func parseTiles(from string: String) throws -> [[Tile]] {
    return try string
        .lines
        .map { line in
            try line.map { character in
                switch character {
                case "#":
                    return .bug
                case ".":
                    return .empty
                default:
                    throw ParseError<Tile>(line)
                }
            }
        }
}

private struct Position: Hashable {
    let x: Int
    let y: Int
    let z: Int
}

private enum Tile {
    case bug
    case empty
}
