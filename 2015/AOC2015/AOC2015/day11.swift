//
//  day11.swift
//  AOC2015
//
//  Created by Arthur Dexter on 11/21/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import Foundation

func day11() throws {
    let oldPassword = try readInput(day: 11).trimmingCharacters(in: .whitespacesAndNewlines)
    let newPassword = incrementPassword(oldPassword)
    print("Day 11, part01: New password=\(newPassword)")

    let newNewPassword = incrementPassword(newPassword)
    print("Day 11, part02: New password=\(newNewPassword)")
}

fileprivate func incrementPassword(_ password: String) -> String {
    func doIncrement(_ password: inout [UInt8]){
        var digitIndex = password.count - 1
        while digitIndex >= 0 {
            password[digitIndex] += 1
            if password[digitIndex] < Count {
                break
            } else {
                password[digitIndex] = 0
                digitIndex -= 1
            }
        }
    }

    func isValid(_ password: [UInt8]) -> Bool {
        var containsIncreasingStraight = false
        var containsProhibitedLetter = false
        var pairs = Set<[UInt8]>()

        var previousPrevious: UInt8?
        var previous: UInt8?
        for current in password {
            // Passwords must include one increasing straight of at least three letters, like abc, bcd, cde, and so on, up to xyz. They cannot skip letters; abd doesn't count.
            if
                let previousPrevious = previousPrevious,
                let previous = previous,
                previous > 0, previousPrevious == previous - 1,
                current > 0, previous == current - 1
            {
                containsIncreasingStraight = true
            }

            // Passwords may not contain the letters i, o, or l, as these letters can be mistaken for other characters and are therefore confusing.
            if ProhibitedValues.contains(current) {
                containsProhibitedLetter = true
                break
            }

            // Passwords must contain at least two different, non-overlapping pairs of letters, like aa, bb, or zz.
            if current == previous {
                pairs.insert([current, current])
            }

            previousPrevious = previous
            previous = current
        }
        return containsIncreasingStraight && !containsProhibitedLetter && pairs.count > 1
    }

    var passwordValues: [UInt8] = password.utf8.map { UInt8($0) - AValue }
    while true {
        doIncrement(&passwordValues)
        if isValid(passwordValues) {
            break
        }
    }
    return String(passwordValues.map { Character(Unicode.Scalar($0 + AValue)) })
}

private let AValue = UInt8(Unicode.Scalar("a").value)
private let ProhibitedValues = Set<UInt8>(
    [
        Unicode.Scalar("i"),
        Unicode.Scalar("o"),
        Unicode.Scalar("l")
    ].map {
        UInt8($0.value) - AValue
    })
private let Count = UInt8(Unicode.Scalar("z").value) - AValue + 1
