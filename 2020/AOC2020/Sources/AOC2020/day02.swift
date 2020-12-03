//
//  day02.swift
//  AOC2020
//
//  Created by Arthur Dexter on 12/3/20.
//

import AdventOfCodeUtils
import Foundation

//--- Day 2: Password Philosophy ---
//
//Your flight departs in a few days from the coastal airport; the easiest way down to the coast from here is via toboggan.
//
//The shopkeeper at the North Pole Toboggan Rental Shop is having a bad day. "Something's wrong with our computers; we can't log in!" You ask if you can take a look.
//
//Their password database seems to be a little corrupted: some of the passwords wouldn't have been allowed by the Official Toboggan Corporate Policy that was in effect when they were chosen.
//
//To try to debug the problem, they have created a list (your puzzle input) of passwords (according to the corrupted database) and the corporate policy when that password was set.
//
//For example, suppose you have the following list:
//
//1-3 a: abcde
//1-3 b: cdefg
//2-9 c: ccccccccc
//
//Each line gives the password policy and then the password. The password policy indicates the lowest and highest number of times a given letter must appear for the password to be valid. For example, 1-3 a means that the password must contain a at least 1 time and at most 3 times.
//
//In the above example, 2 passwords are valid. The middle password, cdefg, is not; it contains no instances of b, but needs at least 1. The first and third passwords are valid: they contain one a or nine c, both within the limits of their respective policies.
//
//How many passwords are valid according to their policies?

func day02part01() throws {
    let validPasswords = try readInput()
        .lines
        .map(parse(_:))
        .filter { (entry: PasswordEntry) -> Bool in
            var matchIndexes: [String.Index] = []
            var searchIndex = entry.password.startIndex
            while searchIndex < entry.password.endIndex {
                if let matchIndex = entry.password[searchIndex...].firstIndex(of: entry.ruleString) {
                    matchIndexes.append(matchIndex)
                    searchIndex = entry.password.index(after: matchIndex)
                } else {
                    break
                }
            }

            return entry.ruleRange ~= matchIndexes.count
        }
    print("Day 02, part 01: \(validPasswords.count)") // 456
}

//--- Part Two ---
//
//While it appears you validated the passwords correctly, they don't seem to be what the Official Toboggan Corporate Authentication System is expecting.
//
//The shopkeeper suddenly realizes that he just accidentally explained the password policy rules from his old job at the sled rental place down the street! The Official Toboggan Corporate Policy actually works a little differently.
//
//Each policy actually describes two positions in the password, where 1 means the first character, 2 means the second character, and so on. (Be careful; Toboggan Corporate Policies have no concept of "index zero"!) Exactly one of these positions must contain the given letter. Other occurrences of the letter are irrelevant for the purposes of policy enforcement.
//
//Given the same example list from above:
//
//    1-3 a: abcde is valid: position 1 contains a and position 3 does not.
//    1-3 b: cdefg is invalid: neither position 1 nor position 3 contains b.
//    2-9 c: ccccccccc is invalid: both position 2 and position 9 contain c.
//
//How many passwords are valid according to the new interpretation of the policies?

func day02part02() throws {
    let validPasswords = try readInput()
        .lines
        .map(parse(_:))
        .filter { (entry: PasswordEntry) -> Bool in
            guard entry.ruleRange.upperBound <= entry.password.count else {
                return false
            }
            let ruleStringMatches = [entry.ruleRange.lowerBound, entry.ruleRange.upperBound]
                .map { (index: Int) -> String.Index in
                    // offset by 1 since String is 0-indexed and ruleRange is 1-indexed
                    // convert to String.Index
                    entry.password.index(entry.password.startIndex, offsetBy: index - 1)
                }
                .filter { (index: String.Index) -> Bool in
                    entry.password[index] == entry.ruleString
                }
            return ruleStringMatches.count == 1
        }
    print("Day 02, part 01: \(validPasswords.count)") // 308
}

private struct PasswordEntry {
    let ruleRange: ClosedRange<Int>
    let ruleString: Character
    let password: String
}

private func parse<S: StringProtocol>(_ line: S) throws -> PasswordEntry {
    let tokens = line
        .replacingOccurrences(of: ":", with: "")
        .replacingOccurrences(of: "-", with: " ")
        .split(separator: " ")
    guard tokens.count == 4 else {
        throw ParseError<String>("Wrong number of tokens in '\(line)'")
    }
    guard tokens[2].count == 1 else {
        throw ParseError<String>("Wrong token length for rule: '\(tokens[2])'")
    }
    return try PasswordEntry(
        ruleRange: (Int.parse(tokens[0]))...(Int.parse(tokens[1])),
        ruleString: tokens[2][tokens[2].startIndex],
        password: String(tokens[3])
    )
}
