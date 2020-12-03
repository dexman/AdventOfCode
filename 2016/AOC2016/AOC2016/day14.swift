//
//  day14.swift
//  AOC2016
//
//  Created by Arthur Dexter on 12/3/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import AdventOfCodeUtils
import CryptoKit
import Foundation

func day14() throws {
    let salt = try readInput().trimmingCharacters(in: .whitespacesAndNewlines)

    let part1Gen = KeyGenerator(salt: salt, stretching: false)
    let part1Keys: [(key: String, index: Int)] = (0..<64).map { _ in
        part1Gen.generateNextKey()
    }
    print("Day 14, part 01: Index of 64th key=\(part1Keys[part1Keys.count - 1].index)")

    let part2Gen = KeyGenerator(salt: salt, stretching: true)
    let part2Keys: [(key: String, index: Int)] = (0..<64).map { _ in
        part2Gen.generateNextKey()
    }
    print("Day 14, part 02: Index of 64th key=\(part2Keys[part2Keys.count - 1].index)")
}

class KeyGenerator {

    init(salt: String, stretching: Bool) {
        self.salt = salt.utf8.map { $0 }
        self.stretching = stretching
        self.strings = []
        self.stringsIndex = 0
    }

    func generateNextKey() -> (key: String, index: Int) {
        while !isValidKey(at: stringsIndex) {
            stringsIndex += 1
        }
        let stringBytes = string(at: stringsIndex)
        let string = String(bytes: stringBytes, encoding: .utf8)!
        let result = (string, stringsIndex)
        stringsIndex += 1
        return result
    }

    private let salt: [UInt8]
    private let stretching: Bool
    private var strings: [[UInt8]]
    private var stringsIndex: Int

    private func string(at index: Int) -> [UInt8] {
        while strings.count <= index {
            let string: [UInt8] = salt + "\(strings.count)".utf8.map { $0 }
            var hash = string.md5String
            if stretching {
                for _ in (0..<2016) {
                    hash = hash.md5String
                }
            }
            strings.append(hash)
        }
        return strings[index]
    }

    private func isValidKey(at index: Int) -> Bool {
        let candidate = string(at: index)

        var (twoPrevious, previous): (UInt8?, UInt8?) = (nil, nil)
        var tripletCharacter: UInt8?
        for character in candidate {
            if character == previous, previous == twoPrevious {
                tripletCharacter = character
                break
            }
            twoPrevious = previous
            previous = character
        }

        guard let quintuplet = tripletCharacter.map({ Array(repeating: $0, count: 5) }) else {
            return false
        }

        return ((index + 1)...(index + 1000)).contains {
            string(at: $0).contains(subarray: quintuplet)
        }
    }
}

private let cache: [[UInt8]] = (0...0xff).map {
    String(format: "%02x", $0).utf8.map { $0 }
}

fileprivate extension Array where Element == UInt8 {

    var md5String: [UInt8] {
        let digest = Insecure.MD5.hash(data: self)
        var result: [UInt8] = []
        result.reserveCapacity(Insecure.MD5.byteCount * 2)
        for element in digest {
            result.append(contentsOf: cache[Int(element)])
        }
        return result
    }

    func contains(subarray: [Element]) -> Bool {
        var found = 0
        for element in self where found < subarray.count {
            if element == subarray[found] {
                found += 1
            } else {
                found = element == subarray[0] ? 1 : 0
            }
        }

        return found == subarray.count
    }
}
