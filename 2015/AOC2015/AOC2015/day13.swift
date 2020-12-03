//
//  day13.swift
//  AOC2015
//
//  Created by Arthur Dexter on 11/21/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import Foundation

func day13() throws {
    let happinessValues = try readInput(day: 13).lines.map(parseHappiness)
    var happiness: [String: [String: Int]] = [:]
    for (name, companion, happinessValue) in happinessValues {
        var companions = happiness[name] ?? [:]
        companions[companion] = happinessValue
        happiness[name] = companions
    }
    let part1Names = Set(happiness.keys)
    let part1Arrangements = visit(part1Names)
    let part1HappinessTotals = part1Arrangements.map { totalHappiness($0, happiness: happiness) }
    print("Day 13, part 01: Best happiness=\(part1HappinessTotals.max() ?? 0)")

    let part2Names = Set(happiness.keys + [UUID().uuidString])
    let part2Arrangements = visit(part2Names)
    let part2HappinessTotals = part2Arrangements.map { totalHappiness($0, happiness: happiness) }
    print("Day 13, part 02: Best happiness=\(part2HappinessTotals.max() ?? 0)")
}

fileprivate func totalHappiness(_ arrangement: [String], happiness: [String: [String: Int]]) -> Int {
    var total = 0
    var index = 0
    while index < arrangement.count {
        let currentName = arrangement[index]

        let previousName = index > 0 ? arrangement[index - 1] : arrangement[arrangement.count - 1]
        total += happiness[currentName]?[previousName] ?? 0

        let nextName = index < arrangement.count - 1 ? arrangement[index + 1] : arrangement[0]
        total += happiness[currentName]?[nextName] ?? 0

        index += 1
    }
    return total
}

fileprivate func visit(_ names: Set<String>, _ path: [String] = []) -> [[String]] {
    if names.isEmpty {
        return [path]
    } else {
        return names.flatMap { name -> [[String]] in
            let remainingCities = names.symmetricDifference([name])
            return visit(remainingCities, path + [name])
        }
    }
}

private func parseHappiness<S: StringProtocol>(from string: S) throws -> (String, String, Int) {
    // Mallory would lose 16 happiness units by sitting next to George.
    let tokens = string.trimmingCharacters(in: .punctuationCharacters).split(separator: " ")
    let sign: Bool = tokens[2] == "gain"
    let value: Int = try Int(tokens[3])
    let name = String(tokens[0])
    let companion = String(tokens[10])
    return (
        name,
        companion,
        (sign ? 1 : -1) * value
    )
}
