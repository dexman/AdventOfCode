import AdventOfCodeUtils
import Foundation

func day18() throws {
    let tiles: [Position: Tile] = try parseInput2(from: readInput())
//    print(format2(tiles))

    let part1Length = try findShortestPathLength2(in: tiles)
    print("Day 18, part 01: Shortest path length=\(part1Length)") // 2684 is the correct answer
}

private func findShortestPathLength2(in tiles: [Position: Tile]) throws -> Int {
    let start: (key: Position, value: String) = try (tiles.compactMapValues {
        switch $0 {
        case .start:
            return "@"
        default:
            return nil
        }
    }.first).required()

    let keyTiles: [Position: String] = tiles.compactMapValues {
        switch $0 {
        case let .key(name):
            return name
        default:
            return nil
        }
    }

    var keyToKey: [String: [String: (path: [Position], keysRequired: Set<String>)]] = [:]
    for (srcKeyPosition, srcKey) in keyTiles + [start] {
        for (dstKeyPosition, dstKey) in keyTiles where srcKey != dstKey {
            guard
                let path = aStar(
                    start: srcKeyPosition,
                    goal: dstKeyPosition,
                    distance: { _, _ in 1 },
                    heuristicDistance: { _ in 0 },
                    neighbors: { position in
                        Set(position.neighbors.filter { neighbor in
                            tiles[neighbor]?.isNavigable ?? false
                        })
                    })
            else {
                fatalError("Could not find any path from \(srcKeyPosition) to \(dstKeyPosition)")
            }

            let keysRequired: [String] = path.compactMap {
                switch tiles[$0] {
                case let .door(name):
                    return name.lowercased()
                default:
                    return nil
                }
            }

            keyToKey[srcKey, default: [:]][dstKey] = (
                path: Array(path.dropFirst()),
                keysRequired: Set(keysRequired)
            )
        }
    }

//    for (srcKey, destinations) in keyToKey {
//        print("==========")
//        print("\(srcKey) ==>")
//        for (dstKey, (path, keysRequired)) in destinations {
//            print("    \(dstKey):")
//            print("        \(path)")
//            print("        \(keysRequired)")
//        }
//    }

    struct Node: Hashable {
        let key: String
        let keychain: Set<String>
    }

    func computeTotalPath(_ nodes: [Node]) -> [Position] {
        var totalPath: [Position] = []
        var srcKey: String?
        for node in nodes {
            if let srcKey = srcKey {
                guard let (path, _) = keyToKey[srcKey]?[node.key] else {
                    fatalError("Could not find path from \(srcKey) to \(node.key)")
                }
                totalPath += path
            }
            srcKey = node.key
        }
        return totalPath
    }

    let startNode = Node(key: "@", keychain: [])

    var bestTotalPath: [Position]?
    for (_, dstKey) in keyTiles {
        print("Looking at destination \(dstKey)")
        let goalNode = Node(key: dstKey, keychain: Set(keyTiles.values))
        guard
            let path = aStar(
                start: startNode,
                goal: goalNode,
                distance: { src, dst in
                    guard let (path, _) = keyToKey[src.key]?[dst.key] else {
                        fatalError("No path found from \(src.key) to \(dst.key)")
                    }
                    return path.count
                },
                heuristicDistance: { _ in 0 },
                neighbors: { src in
                    var neighbors: Set<Node> = []
                    for (_, neighborKey) in keyTiles where src.key != neighborKey {
                        guard let (path, keysRequired) = keyToKey[src.key]?[neighborKey] else {
                            fatalError("No path found from \(src.key) to \(neighborKey)")
                        }
                        guard src.keychain.isSuperset(of: keysRequired) else {
                            // Path not possible, don't have the right keys
                            continue
                        }

                        // Pick up any new keys encountered in path
                        let neighborKeychain = src.keychain.union(path.compactMap { keyTiles[$0] })
                        guard neighborKeychain != src.keychain else {
                            // No new keys picked up, ignore this destination.
                            continue
                        }

                        neighbors.insert(Node(key: neighborKey, keychain: neighborKeychain))
                    }
                    return neighbors
                })
        else {
            // Some destinations aren't possible, this is OK.
            continue
        }

        let totalPath: [Position] = computeTotalPath(path)
        if totalPath.count < (bestTotalPath?.count ?? Int.max) {
            bestTotalPath = totalPath
        }
    }

    return try bestTotalPath.required().count
}

private func format2(_ tiles: [Position: Tile]) -> String {
    let width = (tiles.keys.map { $0.x }.max() ?? -1) + 1
    let height = (tiles.keys.map { $0.y }.max() ?? -1) + 1
    return (0..<height).map { y in
        (0..<width).map { x in
            let position = Position(x: x, y: y)
            guard let tile = tiles[position] else {
                fatalError("Missing tile at position \(position)")
            }
            switch tile {
            case .start:
                return "@"
            case let .key(name):
                return name
            case let .door(name):
                return name
            case .empty:
                return "."
            case .wall:
                return "#"
            }
        }.joined()
    }.joined(separator: "\n")
}

private func parseInput2(from string: String) throws -> [Position: Tile] {
    return try Dictionary(uniqueKeysWithValues: string
        .lines
        .enumerated()
        .flatMap { (y, line) -> [(Position, Tile)] in
            try line.enumerated().map { (x, character) -> (Position, Tile) in
                let position = Position(x: x, y: y)
                switch character {
                case "#":
                    return (position, .wall)
                case ".":
                    return (position, .empty)
                case "@":
                    return (position, .start)
                case "A"..."Z":
                    return (position, .door(String(character)))
                case "a"..."z":
                    return (position, .key(String(character)))
                default:
                    throw ParseError<Tile>(line)
                }
            }
        })
}

private struct Position: Hashable, CustomDebugStringConvertible {
    let x: Int
    let y: Int

    var neighbors: [Position] {
        return [
            Position(x: x, y: y - 1),
            Position(x: x, y: y + 1),
            Position(x: x - 1, y: y),
            Position(x: x + 1, y: y),
        ]
    }

    func manhattanDistance(to other: Position) -> Int {
        return abs(other.x - x) + abs(other.y - y)
    }

    var debugDescription: String {
        return "(\(x),\(y))"
    }
}

private enum Tile: Hashable {
    case start
    case key(String)
    case door(String)
    case empty
    case wall

    var isNavigable: Bool {
        switch self {
        case .start, .key, .door, .empty:
            return true
        case .wall:
            return false
        }
    }
}
