//
//  day13.swift
//  AOC2016
//
//  Created by Arthur Dexter on 11/28/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import AdventOfCodeUtils
import Foundation

func day13() throws {
    let favoriteNumber = try Int.parse(readInput().trimmingCharacters(in: .whitespacesAndNewlines))
    let officeSpace = OfficeSpace(favoriteNumber: favoriteNumber)


    let startLocation = Location(x: 1, y: 1)
    let goalLocation = Location(x: 31, y: 39)

    assert(officeSpace.tile(at: startLocation) == .openSpace)

    let part1ShortestPath = try officeSpace.shortestPath(from: startLocation, to: goalLocation).required()
    print("Day 13, part 01: Number of steps=\(part1ShortestPath.count - 1)")

    var reachable: Set<Location> = []
    for y in 0...50 {
        for x in 0...50 {
            let location = Location(x: x, y: y)
            guard startLocation.manhattanDistance(to: location) <= 50 else {
                //print("\(location) is not reachable in 50 steps.")
                continue
            }
            guard officeSpace.tile(at: location) == .openSpace else {
                //print("\(location) is not an open space.")
                continue
            }
            guard let path = officeSpace.shortestPath(from: startLocation, to: location) else {
                //print("\(location) is not reachable.")
                continue
            }
            guard path.count - 1 <= 50 else {
                //print("\(location) is not reachable in 50 steps.")
                continue
            }
            reachable.formUnion(path)
        }
    }
    print("Day 13, part 02: Number of locations=\(reachable.count)")
}

private class OfficeSpace {

    init(favoriteNumber: Int) {
        self.favoriteNumber = favoriteNumber
    }

    func format(maxLocation: Location, path: [Location]) -> String {
        return (0...maxLocation.y).map { y -> String in
            (0...maxLocation.x).map { x -> String in
                let location = Location(x: x, y: y)
                if location == path.first {
                    return "S"
                } else if location == path.last {
                    return "E"
                } else if path.contains(location) {
                    return "O"
                } else {
                    switch tile(at: location) {
                    case .openSpace:
                        return "."
                    case .wall:
                        return "#"
                    }
                }
            }.joined()
        }.joined(separator: "\n")
    }

    func tile(at location: Location) -> Tile {
        let (x, y) = (location.x, location.y)
        let sum = x*x + 3*x + 2*x*y + y + y*y + favoriteNumber
        if sum.nonzeroBitCount % 2 == 0 {
            // If the number of bits that are 1 is even, it's an open space
            return .openSpace
        } else {
            // If the number of bits that are 1 is odd, it's a wall.
            return .wall
        }
    }

    func shortestPath(from src: Location, to dst: Location) -> [Location]? {
        return aStar(
            start: src,
            goal: dst,
            distance: { _, _ in 1 }, // cost to travel to any neighbor is always 1
            heuristicDistance: { $0.manhattanDistance(to: dst) }, // dumb estimate
            neighbors: openSpaces(neighboring:))
    }

    func openSpaces(neighboring location: Location) -> Set<Location> {
        return location.neighbors.filter { self.tile(at: $0) == .openSpace }
    }

    private let favoriteNumber: Int
}

private struct Location: Hashable {
    let x: Int
    let y: Int

    var neighbors: Set<Location> {
        return Set([
            Location(x: x - 1, y: y),
            Location(x: x + 1, y: y),
            Location(x: x, y: y - 1),
            Location(x: x, y: y + 1),
        ].filter {
            $0.x >= 0 && $0.y >= 0
        })
    }

    func manhattanDistance(to other: Location) -> Int {
        return abs(x - other.x) + abs(y - other.y)
    }
}

private enum Tile {
    case openSpace
    case wall
}
