//
//  day04.swift
//  AOC2019
//
//  Created by Arthur Dexter on 12/3/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import AdventOfCodeUtils
import Foundation

func day04() throws {
    let inputRangeArray: [Int] = try readInput()
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .split(separator: "-")
        .map { try Int.parse($0) }
    assert(inputRangeArray.count == 2)
    let inputRange = inputRangeArray[0]...inputRangeArray[1]

    let part1Passwords = inputRange.filter(isPasswordPart1(_:))
    print("Day 04, part 01: Number of passwords in range=\(part1Passwords.count)")

    let part2Passwords = inputRange.filter(isPasswordPart2(_:))
    print("Day 04, part 02: Number of passwords in range=\(part2Passwords.count)")
}

private func isPasswordPart2(_ number: Int) -> Bool {
    var previousDigit: UInt8?
    var currentRunLength: Int = 0
    var runs: [UInt8: [Int]] = [:]
    func runEnded() {
        guard let digit = previousDigit else {
            fatalError("Must have a previous digit")
        }
        runs[digit, default: []].append(currentRunLength)
        currentRunLength = 0
    }

    var hasNonDecreasingDigits: Bool = true

    for digit in number.digits {
        if let previousDigit = previousDigit {
            if digit < previousDigit {
                hasNonDecreasingDigits = false
                break
            }
            if digit != previousDigit {
                runEnded()
            }
        }
        previousDigit = digit
        currentRunLength += 1
    }
    runEnded()

    return runs.values.flatMap { $0 }.contains(2) && hasNonDecreasingDigits
}

private func isPasswordPart1(_ number: Int) -> Bool {
    var previousDigit: UInt8?
    var hasRepeatedDigit: Bool = false
    var hasNonDecreasingDigits: Bool = true
    for digit in number.digits {
        if let previousDigit = previousDigit {
            if digit < previousDigit {
                hasNonDecreasingDigits = false
                break
            }
            if digit == previousDigit {
                hasRepeatedDigit = true
            }
        }
        previousDigit = digit
    }

    return hasRepeatedDigit && hasNonDecreasingDigits
}
