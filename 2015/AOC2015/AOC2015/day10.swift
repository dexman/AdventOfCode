//
//  day10.swift
//  AOC2015
//
//  Created by Arthur Dexter on 11/21/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import Foundation

func day10() throws {
    let input = try readInput(day: 10).trimmingCharacters(in: .whitespacesAndNewlines)

    let part1Result = (0..<40).reduce(input) { digits, _ in
        lookAndSay(digits)
    }
    print("Day 10, part 01: result length=\(part1Result.count)")

    let part2Result = (0..<50).reduce(input) { digits, _ in
        lookAndSay(digits)
    }
    print("Day 10, part 02: result length=\(part2Result.count)")

}

fileprivate func lookAndSay(_ digits: String) -> String {
    var result = ""

    var runLength = 0
    var previousDigit: Character?
    for currentDigit in digits {
        if let previousDigit = previousDigit, previousDigit != currentDigit {
            result.append("\(runLength)\(previousDigit)")
            runLength = 0
        }
        previousDigit = currentDigit
        runLength += 1
    }

    if runLength > 0, let previousDigit = previousDigit {
        result.append("\(runLength)\(previousDigit)")
    }

    return result
}
