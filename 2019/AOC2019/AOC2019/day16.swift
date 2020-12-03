//
//  day16.swift
//  AOC2019
//
//  Created by Arthur Dexter on 12/16/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import AdventOfCodeUtils
import Foundation

func day16() throws {
    let initialInput = try parseInputList(from: try readInput())

    let part1Result = applyFFTPart1(to: initialInput).prefix(8).map { "\($0)" }.joined()
    print("Day 16, part 01: Final output list=\(part1Result)")

    let part2Result = applyFFTPart2(to: initialInput).prefix(8).map { "\($0)" }.joined()
    print("Day 16, part 02: Final output list=\(part2Result)")
}

private func applyFFTPart2(to initialInput: [Int], phaseCount: Int = 100) -> [Int] {
    let skip = Int(initialInput.prefix(7).map { "\($0)" }.joined())!
    var digits: [Int] = Array(repeating: initialInput, count: 10000).flatMap { $0 }

    // Skipping so many digits (5976267 of them) that only 0 and 1 from the base pattern will be used.
    // So we only need to add together the elements that are multiplied by 1.
    assert(digits.count < 2 * skip - 1)

    for _ in 0..<phaseCount {
        for n in (skip..<(digits.count - 2)).reversed() {
            digits[n] = (digits[n] + digits[n + 1]) % 10
        }
    }

    return Array(digits[skip...])
}

private func applyFFTPart1(to initialInput: [Int], phaseCount: Int = 100) -> [Int] {
    var count = 0

    var input = initialInput
    while count < phaseCount {
        var output: [Int] = []
        output.reserveCapacity(input.count)
        var outputElementIndex = 0
        while outputElementIndex < input.count {
            var outputElement: Int = 0
            var inputElementIndex = outputElementIndex
            while inputElementIndex < input.count {
                let inputElement = input[inputElementIndex]
                let p = patternValue(inputElementIndex: inputElementIndex, outputElementIndex: outputElementIndex)
                if p > 0 {
                    outputElement += inputElement
                } else if p < 0 {
                    outputElement -= inputElement
                }
                inputElementIndex += 1
            }
            output.append(abs(outputElement) % 10)
            outputElementIndex += 1
        }
        input = output
        count += 1
    }

    return input
}

private let basePattern: [Int] = [0, 1, 0, -1]

private func patternValue(inputElementIndex: Int, outputElementIndex: Int) -> Int {
    let repetitionIndex = (inputElementIndex + 1) / (outputElementIndex + 1)
    let patternIndex = repetitionIndex % basePattern.count
    return basePattern[patternIndex]
}

private func parseInputList(from string: String) throws -> [Int] {
    return try string
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .map { try Int.parse(String($0)) }
}
