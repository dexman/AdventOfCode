//
//  day19.swift
//  AOC2015
//
//  Created by Arthur Dexter on 11/22/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import Foundation

func day19() throws {
    let (rules, medicine) = try parseRulesAndMedicine2(from: readInput(day: 19))

    var calibrationMedicines = Set<String>()
    replacementStep2(molecule: medicine, rules: rules, result: &calibrationMedicines)
    print("Day 19, part 01: Number of calibration medicines=\(calibrationMedicines.count)")

    var reverseRules: [String: String] = [:]
    for (pattern, replacements) in rules {
        for replacement in replacements {
            assert(reverseRules[replacement] == nil)
            reverseRules[replacement] = pattern
        }
    }
    let reverseRuleKeys = reverseRules.keys.sorted { lhs, rhs -> Bool in
        rhs.count < lhs.count
    }

    var molecule = medicine
    var steps = 0
    while molecule != "e" {
        for key in reverseRuleKeys {
            if let match = molecule.range(of: key), let value = reverseRules[key] {
                molecule.replaceSubrange(match, with: value)
                steps += 1
                break
            }
        }
    }
    print("Day 19, part 02: Number of steps=\(steps)")
}

private func replacementStep2(molecule: String, rules: [String: [String]], result: inout Set<String>) {
    for (pattern, replacements) in rules {
        var index = molecule.startIndex
        while index < molecule.endIndex {
            let matchRange = molecule.range(of: pattern, range: index..<molecule.endIndex)
            if let matchRange = matchRange {
                for replacement in replacements {
                    result.insert(molecule.replacingCharacters(in: matchRange, with: replacement))
                }
                index = matchRange.upperBound
            } else {
                index = molecule.endIndex
            }
        }
    }
}

private func parseRulesAndMedicine2<S: StringProtocol>(from string: S) throws -> ([String: [String]], String) {
    let lines = string.lines

    let rules: [(String, String)] = try lines
        .filter { $0.contains(" => ") }
        .map { $0.split(separator: " => " ) }
        .map {
            guard $0.count == 2 else {
                throw ParseError<[String: String]>(string)
            }
            return (String($0[0]), String($0[1]))
        }
    var rulesDict: [String: [String]] = [:]
    for (pattern, replacement) in rules {
        rulesDict[pattern, default: []].append(replacement)
    }

    guard let medicine = lines.last?.trimmingCharacters(in: .whitespacesAndNewlines) else {
        throw ParseError<[String: String]>(string)
    }

    return (rulesDict, medicine)
}
