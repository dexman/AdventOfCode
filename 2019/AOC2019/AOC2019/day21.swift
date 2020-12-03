//
//  day21.swift
//  AOC2019
//
//  Created by Arthur Dexter on 1/8/20.
//  Copyright © 2020 Arthur Dexter. All rights reserved.
//

import AdventOfCodeUtils
import Foundation

func day21() throws {
    let code = try IntcodeProcessor.parseIntcode(from: readInput())

    let part1Program: [String] = [
        // Jump if a hole is 1 away and a ground is 4 away
        "NOT A J",
        "AND D J",

        // Jump if a hole is 3 away and a ground is 4 away
        "NOT C T",
        "AND D T",
        "OR T J",

        "WALK\n",
    ]

    let part1HullDamage = runSpringdroid(code: code, program: part1Program)
    print("Day 21, part 01: Amount of hull damage=\(part1HullDamage)")

    // (!A || !B || !C) && D && H || !A
    let part2Program: [String] = [
        "OR A J",
        "AND B J",
        "AND C J",
        "NOT J J",

        "AND D J",
        "AND H J",

        "NOT A T",
        "OR T J",

        "RUN\n",
    ]

    let part2HullDamage = runSpringdroid(code: code, program: part2Program)
    print("Day 21, part 02: Amount of hull damage=\(part2HullDamage)")
}

private func runSpringdroid(code: [Int], program: [String]) -> Int {
    var input: [Int] = program
        .joined(separator: "\n")
        .utf8
        .map { Int($0) }

    var output: String = ""
    var lastOutputValue: Int?

    let processor = IntcodeProcessor(
        memory: code,
        input: {
            guard !input.isEmpty else {
                fatalError("Input buffer underflow")
            }
            return input.removeFirst()
        },
        output: {
            if let outputCharacter = Unicode.Scalar($0).map(Character.init) {
                output.append(outputCharacter)
            } else {
                lastOutputValue = $0
            }
        })
    while processor.canStep { processor.step() }

    if let hullDamage = lastOutputValue {
        return hullDamage
    } else {
        fatalError("failed to complete:\n\(output)")
    }
}
