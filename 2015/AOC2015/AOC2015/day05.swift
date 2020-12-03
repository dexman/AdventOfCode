//
//  day05.swift
//  AOC2015
//
//  Created by Arthur Dexter on 11/20/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import Foundation

func day05() throws {
    let lines = try readInput(day: 5).lines

    let numberOfPart1Nice = lines.filter { $0.isPart1Nice }.count
    let numberOfPart2Nice = lines.filter { $0.isPart2Nice }.count
    print("Day 05, part 01: Number of nice=\(numberOfPart1Nice)")
    print("Day 05, part 02: Number of nice=\(numberOfPart2Nice)")
}

extension StringProtocol {

    fileprivate var isPart1Nice: Bool {
        var vowelsCount = 0
        var containsDoubleLetter = false
        var containsProhibitedString = false

        let unicodeScalars = self.unicodeScalars
        var index = unicodeScalars.startIndex
        var previousIndex: String.UnicodeScalarView.Index?
        while index < unicodeScalars.endIndex {
            let previousUnicodeScalar = previousIndex.map { unicodeScalars[$0] }
            let unicodeScalar = unicodeScalars[index]
            if CharacterSet.vowels.contains(unicodeScalar) {
                vowelsCount += 1
            }
            if previousUnicodeScalar == unicodeScalar {
                containsDoubleLetter = true
            }
            if let previous = previousUnicodeScalar, prohibitedStrings.contains([previous, unicodeScalar]) {
                containsProhibitedString = true
                break
            }
            previousIndex = index
            index = unicodeScalars.index(after: index)
        }

        return vowelsCount >= 3 && containsDoubleLetter && !containsProhibitedString
    }

    fileprivate var isPart2Nice: Bool {
        var pairs: [[Unicode.Scalar]: [String.UnicodeScalarView.Index]] = [:]
        var containsRepeat = false

        let unicodeScalars = self.unicodeScalars
        var index = unicodeScalars.startIndex
        var previousIndex: String.UnicodeScalarView.Index?
        var previousPreviousIndex: String.UnicodeScalarView.Index?
        while index < unicodeScalars.endIndex {
            let unicodeScalar = unicodeScalars[index]
            if let previousIndex = previousIndex {
                let previousUnicodeScalar = unicodeScalars[previousIndex]
                let pair = [previousUnicodeScalar, unicodeScalar]
                var positions = pairs[pair] ?? []
                positions.append(previousIndex)
                pairs[pair] = positions
            }
            if let previousPrevious = previousPreviousIndex.map({ unicodeScalars[$0] }), previousPrevious == unicodeScalar {
                containsRepeat = true
            }

            previousPreviousIndex = previousIndex
            previousIndex = index
            index = unicodeScalars.index(after: index)
        }

        return containsRepeat && pairs.values.contains { positions -> Bool in
            if positions.count < 2 {
                return false
            }
            return positions.contains { lhs in
                positions.contains { rhs in
                    (rhs.utf16Offset(in: self) - lhs.utf16Offset(in: self)) > 1
                }
            }
        }
    }
}

extension CharacterSet {

    static let vowels: CharacterSet = CharacterSet(charactersIn: "aeiou")
}

private var prohibitedStrings = Set<[Unicode.Scalar]>([
    "ab",
    "cd",
    "pq",
    "xy"
].map {
    Array($0.unicodeScalars)
})
