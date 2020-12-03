//
//  day15.swift
//  AOC2016
//
//  Created by Arthur Dexter on 12/4/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import AdventOfCodeUtils
import Foundation

func day15() throws {
    let discs: [Disc] = try readInput().lines.map(parseDisc(from:))

    let buttonPressTimePart1 = try (0...Int.max).first(where: { time -> Bool in
        canCapsuleFallThrough(discs, buttonPressTime: time)
    }).required()
    print("Day 15, part 01: Press button at time=\(buttonPressTimePart1)")

    let part2Discs: [Disc] = discs + [Disc(numberOfPositions: 11, initialPosition: 0)]
    let buttonPressTimePart2 = try (0...Int.max).first(where: { time -> Bool in
        canCapsuleFallThrough(part2Discs, buttonPressTime: time)
    }).required()
    print("Day 15, part 02: Press button at time=\(buttonPressTimePart2)")
}

private func canCapsuleFallThrough(_ discs: [Disc], buttonPressTime: Int) -> Bool {
    return discs.enumerated().allSatisfy { arg -> Bool in
        let (timeOffset, disc) = arg
        let position = (disc.initialPosition + timeOffset + 1 + buttonPressTime) % disc.numberOfPositions
        return position == 0
    }
}

private func parseDisc(from string: String) throws -> Disc {
    let tokens = string
        .replacingOccurrences(of: ".", with: "")
        .split(separator: " ")
        .dropFirst(3)
    let numberOfPositions: Int = try Int.parse(tokens.first ?? "")
    let initialPosition: Int = try Int.parse(tokens.last ?? "")
    return Disc(numberOfPositions: numberOfPositions, initialPosition: initialPosition)
}

private struct Disc {
    let numberOfPositions: Int
    let initialPosition: Int
}
