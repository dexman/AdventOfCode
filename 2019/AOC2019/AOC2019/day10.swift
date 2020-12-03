//
//  day10.swift
//  AOC2019
//
//  Created by Arthur Dexter on 12/9/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import AdventOfCodeUtils
import Foundation

func day10() throws {
    let grid = try parseGrid(from: readInput())

    let visible: [(coordinate: Coordinate, visible: [Coordinate])] = asteroids(in: grid).map { asteroid in
        (asteroid, allVisible(from: asteroid, in: grid))
    }
    let bestAsteroid = try visible.max { (lhs, rhs) -> Bool in
        lhs.visible.count < rhs.visible.count
    }.required()
    print("Day 10, part 01: Best asteroid position=\(bestAsteroid.coordinate) count=\(bestAsteroid.visible.count)")

    let laserCoordinate = bestAsteroid.coordinate
    var currentGrid = grid
    var vaporized: [Coordinate] = []
    while true {
        let asteroidsToVaporize = allVisible(from: laserCoordinate, in: currentGrid)
            .sorted { lhs, rhs -> Bool in
                laserCoordinate.vaporizationAngle(to: lhs) < laserCoordinate.vaporizationAngle(to: rhs)
            }
            .filter {
                $0 != laserCoordinate
            }
        if asteroidsToVaporize.isEmpty {
            break
        }

        for otherAsteroid in asteroidsToVaporize {
            currentGrid[otherAsteroid.y][otherAsteroid.x] = .empty
            vaporized.append(otherAsteroid)
        }
    }

    print("Day 10, part 02: 200th vaporized is=\(vaporized[199])")
}

private func allVisible(from source: Coordinate, in grid: [[Tile]]) -> [Coordinate] {
    return asteroids(in: grid).filter { otherasteroid in
        source != otherasteroid && isVisible(from: source, to: otherasteroid, in: grid)
    }
}

private func asteroids(in grid: [[Tile]]) -> [Coordinate] {
    return grid.enumerated().flatMap { arg -> [Coordinate] in
        let (y, row) = arg
        return row.enumerated().compactMap { arg -> Coordinate? in
            let (x, tile) = arg
            switch tile {
            case .asteroid:
                return Coordinate(x: x, y: y)
            case .empty:
                return nil
            }
        }
    }
}

private func isVisible(from lhs: Coordinate, to rhs: Coordinate, in grid: [[Tile]]) -> Bool {
    let deltaX = rhs.x - lhs.x
    let deltaY = rhs.y - lhs.y

    let divisor = greatestCommonDivisor(abs(deltaX), abs(deltaY))
    let minDeltaX = deltaX / divisor
    let minDeltaY = deltaY / divisor

    var current = lhs
    while current != rhs, current.x >= 0, current.y >= 0, current.y < grid.count, current.x < grid[current.y].count {
        current = Coordinate(
            x: current.x + minDeltaX,
            y: current.y + minDeltaY)
        if grid[current.y][current.x] == .asteroid {
            break
        }
    }
    return current == rhs
}

func greatestCommonDivisor(_ lhs: Int, _ rhs: Int) -> Int {
    if lhs == 0 {
        return rhs
    } else if rhs == 0 {
        return lhs
    } else if lhs.isEven, rhs.isEven {
        // both even
        return 2 * greatestCommonDivisor(lhs / 2, rhs / 2)
    } else if lhs.isEven {
        // rhs is odd
        return greatestCommonDivisor(lhs / 2, rhs)
    } else if rhs.isEven {
        // lhs is odd
        return greatestCommonDivisor(lhs, rhs / 2)
    } else {
        // both odd
        let u: Int = max(lhs, rhs)
        let v: Int = min(lhs, rhs)
        return greatestCommonDivisor((u - v) / 2, v)
    }
}

private extension FixedWidthInteger {

    var isEven: Bool {
        return self % 2 == 0
    }
}

private func parseGrid(from string: String) throws -> [[Tile]] {
    let asteroids: [[Tile]] = try string.lines.map { (line: String) -> [Tile] in
        return try line.map { (character: String.Element) -> Tile in
            switch character {
            case "#":
                return .asteroid
            case ".":
                return .empty
            default:
                throw ParseError<Tile>(line)
            }
        }
    }

    let counts = asteroids.map { $0.count }
    guard counts.min() == counts.max() else {
        throw ParseError<[[Tile]]>(string)
    }

    return asteroids
}

private enum Tile: Equatable {
    case empty
    case asteroid
}

private struct Coordinate: Hashable, CustomDebugStringConvertible {
    let x: Int
    let y: Int

    func vaporizationAngle(to other: Coordinate) -> Double {
        let originVector = Coordinate(x: 0, y: -1)
        let otherVector = Coordinate(x: other.x - x, y: other.y - y)
        return originVector.angle(to: otherVector)
    }

    func angle(to other: Coordinate) -> Double {
        let cosTheta = multiply(to: other) / (magnitude * other.magnitude)
        let radians = acos(cosTheta)
        let angle = radians * 180 / .pi
        if other.x >= x {
            return angle
        } else {
            return 360.0 - angle
        }
    }

    func multiply(to other: Coordinate) -> Double {
        return Double(x * other.x + y * other.y)
    }

    var magnitude: Double {
        return sqrt(Double(x * x + y * y))
    }

    var debugDescription: String {
        return "(\(x),\(y))"
    }
}
