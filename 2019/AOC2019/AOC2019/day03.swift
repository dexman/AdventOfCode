//
//  day03.swift
//  AOC2019
//
//  Created by Arthur Dexter on 12/3/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import AdventOfCodeUtils
import Foundation

func day03() throws {
    let wires: [[Run]] = try readInput().lines.map(parseWires(from:))
    let wirePoints: [[Point]] = wires.map(points(from:))
    assert(wirePoints.count == 2)
    let wirePoints0: [Point] = wirePoints[0]
    let wirePoints1: [Point] = wirePoints[1]
    let wirePointsSet0: Set<Point> = Set(wirePoints0)
    let wirePointsSet1: Set<Point> = Set(wirePoints1)
    let intersections: Set<Point> = wirePointsSet0.intersection(wirePointsSet1)

    let part1Intersection = try intersections.min(by: Point.distanceFromOriginLess(_:_:)).required()
    print("Day 03, part 01: Closest intersection distance=\(part1Intersection.distanceFromOrigin)")

    let pointSteps0: [Point: Int] = steps(for: wirePoints0)
    let pointSteps1: [Point: Int] = steps(for: wirePoints1)
    let intersectionDistances: [Int] = intersections.compactMap { (point: Point) -> Int? in
        let wireSteps0 = pointSteps0[point, default: pointSteps0.count]
        let wireSteps1 = pointSteps1[point, default: pointSteps1.count]
        return wireSteps0 + wireSteps1
    }
    let part2Distance = try intersectionDistances.min().required()
    print("Day 03, part 02: Shortest intersection distance=\(part2Distance)")
}

private func steps(for points: [Point]) -> [Point: Int] {
    // +1 becasue the 0th point is 1 step away from the origin.
    let pointsAndSteps = points.enumerated().map { ($0.element, $0.offset + 1) }
    return Dictionary(pointsAndSteps) { min($0, $1) }
}

private func points(from wire: [Run]) -> [Point] {
    var result: [Point] = []
    var (x, y): (Int, Int) = (0, 0)
    for run in wire {
        switch run {
        case var .left(distance):
            while distance > 0 {
                x -= 1
                distance -= 1
                result.append(Point(x: x, y: y))
            }
        case var .right(distance):
            while distance > 0 {
                x += 1
                distance -= 1
                result.append(Point(x: x, y: y))
            }
        case var .up(distance):
            while distance > 0 {
                y += 1
                distance -= 1
                result.append(Point(x: x, y: y))
            }
        case var .down(distance):
            while distance > 0 {
                y -= 1
                distance -= 1
                result.append(Point(x: x, y: y))
            }
        }
    }
    return result
}

private func parseWires<S: StringProtocol>(from string: S) throws -> [Run] {
    return try string
        .split(separator: ",")
        .map { (token: S.SubSequence) -> Run in
            let distance = try Int.parse(token.dropFirst())
            switch token.first {
            case "L":
                return .left(distance)
            case "R":
                return .right(distance)
            case "U":
                return .up(distance)
            case "D":
                return .down(distance)
            default:
                throw ParseError<Run>(token)
            }
        }
}

private enum Run {
    case left(Int)
    case right(Int)
    case up(Int)
    case down(Int)
}

private struct Point: Hashable {
    let x: Int
    let y: Int

    var distanceFromOrigin: Int {
        return abs(x) + abs(y)
    }

    static func distanceFromOriginLess(_ lhs: Point, _ rhs: Point) -> Bool {
        return lhs.distanceFromOrigin < rhs.distanceFromOrigin
    }
}
