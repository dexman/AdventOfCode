//
//  day14.swift
//  AOC2019
//
//  Created by Arthur Dexter on 12/19/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import AdventOfCodeUtils
import Foundation

func day14() throws {
    let reactions = try parseReactions(from: readInput())

    let inputs = calculateIt(fuel: 1, inputs: [:], reactions: reactions)
    let requiredOrePerFuel = abs(inputs["ORE", default: 0])
    print("Day 14, part 01: 1 FUEL needs \(requiredOrePerFuel) ORE")

    var (first, last) = (0, 3000000)
    var it = 0
    var count = last - first
    var step = 0
    while count > 0 {
        it = first
        step = count / 2
        it += step

        let remaining = calculateIt(fuel: it, inputs: ["ORE": 1000000000000], reactions: reactions)
        if -remaining["ORE", default: 0] < 0 {
            it += 1
            first = it
            count -= step + 1
        } else {
            count = step
        }
    }

    while true {
        let remaining = calculateIt(fuel: first, inputs: ["ORE": 1000000000000], reactions: reactions)
        if remaining["ORE", default: 0] >= 0 {
            break
        } else {
            first -= 1
        }
    }
    print("Day 14, part 02: Can create \(first) FUEL") // 2269325
}

private func calculateIt(fuel: Int, inputs: [String: Int], reactions: [Reaction]) -> [String: Int] {
    var chemicals: [String: Int] = inputs
    chemicals["FUEL", default: 0] -= fuel

    while true {
        guard
            let reaction = reactions.first(where: { reaction in
                chemicals[reaction.output.chemical, default: 0] < 0
            })
        else {
            // No reaction possible
            break
        }

        let factor = max(1, abs(chemicals[reaction.output.chemical, default: 0] / reaction.output.quantity))
        chemicals[reaction.output.chemical, default: 0] += factor * reaction.output.quantity
        for (chemical, quantity) in reaction.inputs {
            chemicals[chemical, default: 0] -= factor * quantity
        }
    }

    return chemicals.compactMapValues { $0 == 0 ? nil : $0 }
}

private func parseReactions(from string: String) throws -> [Reaction] {
    return try string
        .lines
        .map { line -> Reaction in
            let parts = line.split(separator: " => ")
            guard parts.count == 2 else { throw ParseError<Reaction>(line) }
            let inputs = try (parts.first?.split(separator: ", ").map(parseChemical(from:))).required()
            let output = try parts.last.map(parseChemical(from:)).required()
            return Reaction(inputs: Dictionary(uniqueKeysWithValues: inputs), output: output)
        }
}

private func parseChemical<S: StringProtocol>(from string: S) throws -> (chemical: String, quantity: Int) {
    let tokens = string.split(separator: " ")
    guard tokens.count == 2 else { throw ParseError<(chemical: String, quantity: Int)>(string) }
    let quantity = try tokens.first.flatMap { Int($0) }.required()
    let chemical = try String(tokens.last.required())
    return (chemical, quantity)
}

private struct Reaction: CustomDebugStringConvertible {
    let inputs: [String: Int]
    let output: (chemical: String, quantity: Int)

    var debugDescription: String {
        let inputsString = inputs.map { (chemical, quantity) in
            "\(quantity) \(chemical)"
        }.joined(separator: ", ")
        return "\(inputsString) => \(output.quantity) \(output.chemical)"
    }
}
