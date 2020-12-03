//
//  day06.swift
//  AOC2015
//
//  Created by Arthur Dexter on 11/20/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import Foundation

func day06() throws {
    let lines = try readInput(day: 6).lines
    let instructions: [Instruction] = try lines.compactMap { line in
        let tokens = line.split(separator: " ")
        if tokens.count == 4 {
            return try Instruction(
                bottomLeft: parsePosition(from: tokens[1]),
                topRight: parsePosition(from: tokens[3]),
                operation: .toggle)
        } else if tokens.count == 5 {
            return try Instruction(
                bottomLeft: parsePosition(from: tokens[2]),
                topRight: parsePosition(from: tokens[4]),
                operation: .set(tokens[1] == "on"))
        } else {
            return nil
        }
    }

    var part1Lights: [[Bool]] = Array(
        repeating: Array(repeating: false, count: 1000),
        count: 1000)
    for instruction in instructions {
        switch instruction.operation {
        case let .set(value):
            for y in instruction.bottomLeft.y...instruction.topRight.y {
                for x in instruction.bottomLeft.x...instruction.topRight.x {
                    part1Lights[y][x] = value
                }
            }
        case .toggle:
            for y in instruction.bottomLeft.y...instruction.topRight.y {
                for x in instruction.bottomLeft.x...instruction.topRight.x {
                    part1Lights[y][x] = !part1Lights[y][x]
                }
            }
        }
    }

    print("Day 06, part 01: numberOfLightsOn=\(part1Lights.numberOfLightsOn)")

    var part2Lights: [[Int]] = Array(
        repeating: Array(repeating: 0, count: 1000),
        count: 1000)
    for instruction in instructions {
        switch instruction.operation {
        case let .set(value):
            for y in instruction.bottomLeft.y...instruction.topRight.y {
                for x in instruction.bottomLeft.x...instruction.topRight.x {
                    part2Lights[y][x] = max(part2Lights[y][x] + (value ? 1 : -1), 0)
                }
            }
        case .toggle:
            for y in instruction.bottomLeft.y...instruction.topRight.y {
                for x in instruction.bottomLeft.x...instruction.topRight.x {
                    part2Lights[y][x] = part2Lights[y][x] + 2
                }
            }
        }
    }

    print("Day 06, part 02: totalBrightness=\(part2Lights.totalBrightness)")
}

fileprivate extension Array where Element == Array<Bool> {

    var numberOfLightsOn: Int {
        return map {
            $0.reduce(0) { result, value in value ? result + 1 : result }
        }
        .reduce(0, +)
    }
}

fileprivate extension Array where Element == Array<Int> {

    var totalBrightness: Int {
        return map { $0.reduce(0, +) }.reduce(0, +)
    }
}

fileprivate func parsePosition<S: StringProtocol>(from string: S) throws -> Position {
    let values = try string.split(separator: ",").map { try Int($0) }
    guard values.count == 2 else {
        throw NSError(domain: "day06", code: 0, userInfo: nil)
    }
    return Position(x: values[0], y: values[1])
}

fileprivate struct Position {
    let x: Int
    let y: Int
}

fileprivate struct Instruction {
    let bottomLeft: Position
    let topRight: Position
    let operation: Operation
}


fileprivate enum Operation {
    case set(Bool)
    case toggle
}
