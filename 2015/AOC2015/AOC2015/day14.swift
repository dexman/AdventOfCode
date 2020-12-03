//
//  day14.swift
//  AOC2015
//
//  Created by Arthur Dexter on 11/21/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import Foundation

func day14() throws {
    let reindeers = try readInput(day: 14).lines.map(parseReindeer(from:))

    var state: [(reindeer: Reindeer, position: Int, points: Int, state: ReindeerState)] = reindeers.map {
        ($0, 0, 0, .flying($0.flyingDuration))
    }

    for _ in 0..<2503 {
        state = state.map { (reindeer, position, points, state) in
            let nextPosition: Int
            let nextState: ReindeerState
            switch state {
            case let .flying(timeRemaining):
                nextPosition = position + reindeer.speed
                if timeRemaining > 1 {
                    nextState = .flying(timeRemaining - 1)
                } else {
                    nextState = .resting(reindeer.restDuration)
                }
            case let .resting(timeRemaining):
                nextPosition = position
                if timeRemaining > 1 {
                    nextState = .resting(timeRemaining - 1)
                } else {
                    nextState = .flying(reindeer.flyingDuration)
                }
            }
            return (reindeer, nextPosition, points, nextState)
        }

        let maxPosition = farthestPosition(from: state)
        state = state.map { (reindeer, position, points, state) in
            let nextPoints = position == maxPosition ? points + 1 : points
            return (reindeer, position, nextPoints, state)
        }
    }

    guard let part1Winner = state.max(by: { $0.position < $1.position }) else {
        throw NSError(domain: "day14", code: 0, userInfo: nil)
    }
    print("Day 14, part 01: Winner=\(part1Winner.reindeer.name) position=\(part1Winner.position)")

    guard let part2Winner = state.max(by: { $0.points < $1.points }) else {
        throw NSError(domain: "day14", code: 0, userInfo: nil)
    }
    print("Day 14, part 02: Winner=\(part2Winner.reindeer.name) points=\(part2Winner.points)")
}

private func farthestPosition(from reindeers: [(reindeer: Reindeer, position: Int, points: Int, state: ReindeerState)]) -> Int {
    let winner = reindeers.max(by: { $0.position < $1.position })
    return winner?.position ?? 0
}

private enum ReindeerState {
    case flying(Int)
    case resting(Int)
}

private func parseReindeer<S: StringProtocol>(from string: S) throws -> Reindeer {
    let tokens = string
        .trimmingCharacters(in: .punctuationCharacters)
        .split(separator: " ")
    return Reindeer(
        name: String(tokens[0]),
        speed: try Int(tokens[3]),
        flyingDuration: try Int(tokens[6]),
        restDuration: try Int(tokens[13]))
}

private struct Reindeer {
    let name: String

    // Kilometers per second
    let speed: Int

    // Seconds
    let flyingDuration: Int

    // Seconds
    let restDuration: Int
}
