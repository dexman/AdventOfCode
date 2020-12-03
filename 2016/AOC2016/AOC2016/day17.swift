//
//  day17.swift
//  AOC2016
//
//  Created by Arthur Dexter on 12/5/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import AdventOfCodeUtils
import CryptoKit
import Foundation

func day17() throws {
    let input = try readInput()
    let mapSize: (width: Int, height: Int) = (4, 4)

    let shortestPathPositions = aStar17(
        start: Position(x: 0, y: 0, path: input),
        isGoal: { (node: Position) -> Bool in
            node.x == (mapSize.width - 1) && node.y == (mapSize.height - 1)
        },
        distance: { _, _ in
            1
        },
        heuristicDistance: { (node: Position) -> Int in
            abs(mapSize.width - node.x - 1) + abs(mapSize.height - node.y - 1)
        },
        neighbors: { (node: Position) -> Set<Position> in
            let passcodeHash: [Character] = Insecure.MD5
                .hash(data: node.path.utf8.map { $0 })
                .prefix(2)
                .map { String(format: "%02x", $0) }
                .joined()
                .map { $0 }
            guard passcodeHash.count == 4 else { fatalError() }

            var neighbors: Set<Position> = []
            if node.y > 0, OpenCharacters.contains(passcodeHash[0]) {
                neighbors.insert(Position(
                    x: node.x,
                    y: node.y - 1,
                    path: node.path + "U"
                ))
            }
            if node.y < mapSize.height - 1, OpenCharacters.contains(passcodeHash[1]) {
                neighbors.insert(Position(
                    x: node.x,
                    y: node.y + 1,
                    path: node.path + "D"
                ))
            }
            if node.x > 0, OpenCharacters.contains(passcodeHash[2]) {
                neighbors.insert(Position(
                    x: node.x - 1,
                    y: node.y,
                    path: node.path + "L"
                ))
            }
            if node.x < mapSize.width - 1, OpenCharacters.contains(passcodeHash[3]) {
                neighbors.insert(Position(
                    x: node.x + 1,
                    y: node.y,
                    path: node.path + "R"
                ))
            }
            return neighbors
        }
    )
    let shortestPath = try (shortestPathPositions?.last).required().path.replacingOccurrences(of: input, with: "")
    print("Day 17, part 01: \(shortestPath)") // RDDRULDDRR

    let longestPathPosition = longestPath(
        start: Position(x: 0, y: 0, path: input),
        isGoal: { (node: Position) -> Bool in
            node.x == (mapSize.width - 1) && node.y == (mapSize.height - 1)
        },
        neighbors: { (node: Position) -> Set<Position> in
            let passcodeHash: [Character] = Insecure.MD5
                .hash(data: node.path.utf8.map { $0 })
                .prefix(2)
                .map { String(format: "%02x", $0) }
                .joined()
                .map { $0 }
            guard passcodeHash.count == 4 else { fatalError() }

            var neighbors: Set<Position> = []
            if node.y > 0, OpenCharacters.contains(passcodeHash[0]) {
                neighbors.insert(Position(
                    x: node.x,
                    y: node.y - 1,
                    path: node.path + "U"
                ))
            }
            if node.y < mapSize.height - 1, OpenCharacters.contains(passcodeHash[1]) {
                neighbors.insert(Position(
                    x: node.x,
                    y: node.y + 1,
                    path: node.path + "D"
                ))
            }
            if node.x > 0, OpenCharacters.contains(passcodeHash[2]) {
                neighbors.insert(Position(
                    x: node.x - 1,
                    y: node.y,
                    path: node.path + "L"
                ))
            }
            if node.x < mapSize.width - 1, OpenCharacters.contains(passcodeHash[3]) {
                neighbors.insert(Position(
                    x: node.x + 1,
                    y: node.y,
                    path: node.path + "R"
                ))
            }
            return neighbors
        }
    )
    let longestPath = try longestPathPosition.required().path.replacingOccurrences(of: input, with: "")
    print("Day 17, part 02: \(longestPath.count)") // RDDRULDDRR
}

struct Position: Hashable {
    let x: Int
    let y: Int
    let path: String
}

private let OpenCharacters: Set<Character> = [
    "b",
    "c",
    "d",
    "e",
    "f",
]

//private let mapString = """
//#########
//#S| | | #
//#-#-#-#-#
//# | | | #
//#-#-#-#-#
//# | | | #
//#-#-#-#-#
//# | | |
//####### V
//"""

/// aStar finds a path from start to goal.
/// distance(current,neighbor) is the weight of the edge from current to neighbor
/// heuristicDistance is the heuristic function. h(n) estimates the cost to reach goal from node n.
private func aStar17<Node: Hashable>(
    start: Node,
    isGoal: (Node) -> Bool,
    distance: (Node, Node) -> Int,
    heuristicDistance: (Node) -> Int,
    neighbors: (Node) -> Set<Node>
) -> [Node]? {
    // https://en.wikipedia.org/wiki/A*_search_algorithm

    func reconstructPath<Node: Hashable>(_ cameFrom: [Node: Node], _ current: Node) -> [Node] {
        var current = current
        var totalPath: [Node] = [current]
        while let next = cameFrom[current] {
            current = next
            totalPath.append(current)
        }
        return totalPath.reversed()
    }

    // For node n, cameFrom[n] is the node immediately preceding it on the cheapest path from start to n currently known.
    var cameFrom: [Node: Node] = [:]

    // For node n, gScore[n] is the cost of the cheapest path from start to n currently known.
    var gScore: [Node: Int] = [start: 0]

    // For node n, fScore[n] := gScore[n] + h(n).
    var fScore: [Node: Int] = [start: heuristicDistance(start)]

    // The set of discovered nodes that may need to be (re-)expanded.
    // Initially, only the start node is known.
    var openSet: Heap<Node> = Heap([start]) { fScore[$0, default: Int.max] < fScore[$1, default: Int.max] }

    // Track the elements in openSet for `contains` operations.
    var openSetElements: Set<Node> = [start]

    while let current = openSet.peek {
        // current is the node in openSet having the lowest fScore[] value

        if isGoal(current) {
            return reconstructPath(cameFrom, current)

        }

        openSet.pop()
        openSetElements.remove(current)

        for neighbor in neighbors(current) {
            // tentative_gScore is the distance from start to the neighbor through current
            let tentative_gScore = gScore[current, default: Int.max] + distance(current, neighbor)
            if tentative_gScore < gScore[neighbor, default: Int.max] {
                // This path to neighbor is better than any previous one. Record it!
                cameFrom[neighbor] = current
                gScore[neighbor] = tentative_gScore
                fScore[neighbor] = gScore[neighbor, default: Int.max] + heuristicDistance(neighbor)
                if !openSetElements.contains(neighbor) {
                    openSet.push(neighbor)
                    openSetElements.insert(neighbor)
                }
            }
        }
    }

    // Open set is empty but goal was never reached
    return nil
}

private func longestPath(
    start: Position,
    isGoal: (Position) -> Bool,
    neighbors: (Position) -> Set<Position>
) -> Position? {
    var longestPath: Position?
    var openSet: Set<Position> = [start]
    var seen: Set<Position> = [start]
    while let current = openSet.first {
        openSet.remove(current)
        if isGoal(current) {
            if current.path.count > (longestPath?.path.count ?? 0) {
                longestPath = current
            }
        } else {
            for neighbor in neighbors(current) {
                if seen.insert(neighbor).inserted {
                    openSet.insert(neighbor)
                }
            }
        }
    }
    return longestPath
}
