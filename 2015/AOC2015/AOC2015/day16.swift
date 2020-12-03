//
//  day16.swift
//  AOC2015
//
//  Created by Arthur Dexter on 11/21/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import Foundation

func day16() throws {
    let sues = try readInput(day: 16).lines.map(parseSue(from:))

    let MFCSAM: [String: Int] = [
        "children": 3,
        "cats": 7,
        "samoyeds": 2,
        "pomeranians": 3,
        "akitas": 0,
        "vizslas": 0,
        "goldfish": 5,
        "trees": 3,
        "cars": 2,
        "perfumes": 1
    ]

    guard let sueIndexPart1 = sues.firstIndex(where: { matchesPart1(sue: $0, MFCSAM: MFCSAM) }) else {
        throw NSError(domain: "day16", code: 0, userInfo: nil)
    }
    print("Day 16, part 01: Sue number=\(sueIndexPart1 + 1)")

    guard let sueIndexPart2 = sues.firstIndex(where: { matchesPart2(sue: $0, MFCSAM: MFCSAM) }) else {
        throw NSError(domain: "day16", code: 0, userInfo: nil)
    }
    print("Day 16, part 02: Sue number=\(sueIndexPart2 + 1)")

}

private func matchesPart2(sue: [String: Int], MFCSAM: [String: Int]) -> Bool {
    for (key, value) in sue {
        if key == "cats" || key == "trees" {
            if let otherValue = MFCSAM[key], value <= otherValue {
                return false
            }
        } else if key == "pomeranians" || key == "goldfish" {
            if let otherValue = MFCSAM[key], value >= otherValue {
                return false
            }
        } else if MFCSAM[key] != value {
            return false
        }
    }
    return true
}

private func matchesPart1(sue: [String: Int], MFCSAM: [String: Int]) -> Bool {
    for (key, value) in sue {
        if MFCSAM[key] != value {
            return false
        }
    }
    return true
}

private func parseSue<S: StringProtocol>(from string: S) throws -> [String: Int] {
    let splits = string
        .replacingOccurrences(of: ":", with: "")
        .replacingOccurrences(of: ",", with: "")
        .split(separator: " ")
        .suffix(from: 2)
    var result: [String: Int] = [:]
    var index = splits.startIndex
    while index + 1 < splits.endIndex {
        result[String(splits[index])] = Int(splits[index + 1])
        index += 2
    }
    return result
}
