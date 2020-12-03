//
//  utilities.swift
//  AOC2015
//
//  Created by Arthur Dexter on 11/19/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import Foundation

func readInputData(day: Int) throws -> Data {
    let formattedDay = String(format: "%02d", day)
    let url = URL(fileURLWithPath: "/Users/adexter/Desktop/AOC2015/AOC2015/day\(formattedDay).txt")
    return try Data(contentsOf: url)
}

func readInput(day: Int) throws -> String {
    let formattedDay = String(format: "%02d", day)
    let url = URL(fileURLWithPath: "/Users/adexter/Desktop/AOC2015/AOC2015/day\(formattedDay).txt")
    return try String(contentsOf: url)
}

extension StringProtocol {

    var lines: [Self.SubSequence] {
        return self.split(separator: "\n")
    }

    func split<S: StringProtocol>(separator: S, maxSplit: Int = Int.max, omittingEmptySubsequences: Bool = true) -> [Self.SubSequence] {
        var result: [Self.SubSequence] = []
        var index = self.startIndex
        while index < self.endIndex {
            if let separatorRange = self.range(of: separator, range: index..<self.endIndex) {
                result.append(self[index..<separatorRange.lowerBound])
                index = separatorRange.upperBound
            } else {
                break
            }
        }
        if index < self.endIndex {
            result.append(self[index..<self.endIndex])
        }
        return result
    }
}

extension RandomAccessCollection {

    var combinations: [[Element]] {
        var result: [[Element]] = []

        let numberOfCombinations = 1 << self.count
        result.reserveCapacity(numberOfCombinations)

        for n in 0..<numberOfCombinations {
            let combinationIndexes: [Int] = n.indexesOfSetBits
            let combination: [Element] = combinationIndexes.map { offset in
                let index = self.index(self.startIndex, offsetBy: offset)
                return self[index]
            }
            result.append(combination)
        }
        return result
    }

    func combinationsFiltered(by filter: ([Element]) -> Bool) -> [[Element]] {
        var result: [[Element]] = []

        let numberOfCombinations = 1 << self.count
        result.reserveCapacity(numberOfCombinations)

        var combination: [Element] = []
        for n in 0..<numberOfCombinations {
            n.eachIndexOfSetBits { offset in
                let index = self.index(self.startIndex, offsetBy: offset)
                combination.append(self[index])
            }
            if filter(combination) {
                result.append(combination)
            }
            combination.removeAll(keepingCapacity: true)
        }
        return result
    }

    func choose(_ k: Int) -> [[Element]] {
        return self.combinations.filter { $0.count == k }
    }
}

extension FixedWidthInteger {

    init<S: StringProtocol>(_ text: S, radix: Int = 10) throws {
        guard let value = Self(text, radix: radix) else {
            throw ParseError<Self>(text)
        }
        self = value
    }

    var hexString: String {
        let padding = 2 * MemoryLayout<Self>.size
        return String(format: "%0\(padding)x", [self])
    }


    var indexesOfSetBits: [Int] {
        var result: [Int] = []

        // https://lemire.me/blog/2018/02/21/iterating-over-set-bits-quickly/
        var bitset = self
        while bitset != 0 {
            let t = bitset & (-1 * bitset)
            let r = bitset.trailingZeroBitCount
            if r < self.bitWidth {
                result.append(r)
            }
            bitset ^= t
        }

        return result
    }

    func eachIndexOfSetBits(_ callback: (Int) -> Void) {
        // https://lemire.me/blog/2018/02/21/iterating-over-set-bits-quickly/
        var bitset = self
        while bitset != 0 {
            let t = bitset & (-1 * bitset)
            let r = bitset.trailingZeroBitCount
            if r < self.bitWidth {
                callback(r)
            }
            bitset ^= t
        }
    }
}

struct ParseError<T>: Error {
    let text: String

    init<S: StringProtocol>(_ text: S) {
        self.text = String(text)
    }
}
