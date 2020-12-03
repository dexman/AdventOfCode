//
//  day16.swift
//  AOC2016
//
//  Created by Arthur Dexter on 12/4/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import AdventOfCodeUtils
import Foundation

func day16() throws {
    let input: [Bool] = parse(try readInput())

    let part1Data = dragonCurveRandomData(count: 272, initialData: input)
    let part1Sum = checksum(part1Data)
    print("Day 16, part 01: Checksum=\(format(part1Sum))")

    let part2Data = dragonCurveRandomData(count: 35651584, initialData: input)
    let part2Sum = checksum(part2Data)
    print("Day 16, part 02: Checksum=\(format(part2Sum))")
}

private func checksum(_ data: [Bool]) -> [Bool] {
    var result: [Bool] = []
    for index in stride(from: data.startIndex, to: data.endIndex, by: 2) {
        let value = data[index] == data[index + 1]
        result.append(value)
    }
    if result.count % 2 != 0 {
        return result
    } else {
        return checksum(result)
    }
}

private func dragonCurveRandomData(count: Int, initialData: [Bool]) -> [Bool] {
    var data = initialData
    while data.count < count {
        data = data + [false] + data.reversed().map { !$0 }
    }
    data.removeLast(data.count - count)
    return data
}

private func parse(_ string: String) -> [Bool] {
    return string
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .map { $0 == "1" }
}

private func format(_ data: [Bool]) -> String {
    return data.map { $0 ? "1" : "0"}.joined()
}
