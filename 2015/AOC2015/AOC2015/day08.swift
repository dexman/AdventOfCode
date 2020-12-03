//
//  day08.swift
//  AOC2015
//
//  Created by Arthur Dexter on 11/20/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import Foundation

func day08() throws {
    let codes = try readInput(day: 8).lines
    let strings = codes.map(decode(_:))

    let codesCount = codes.map { $0.count }.reduce(0, +)
    let stringsCount = strings.map { $0.count }.reduce(0, +)
    print("Day 08, part 01: Length difference=\(codesCount - stringsCount)")

    let encoded = codes.map(encode(_:))
    let encodedCount = encoded.map { $0.count }.reduce(0, +)
    print("Day 08, part 02: Length difference=\(encodedCount - codesCount)")
}

fileprivate func decode<S: StringProtocol>(_ code: S) -> String {
    var string = ""

    // Code always starts and end with ", so ignore those.
    var index = code.index(after: code.startIndex)
    let endIndex = code.index(before: code.endIndex)
    var state = ParseState.character

    while index < endIndex {
        let character = code[index]
        switch state {
        case .character:
            if character == "\\" {
                state = .escaping
            } else {
                string.append(character)
            }
        case .escaping:
            if character == "x" {
                state = .hexDigits("")
            } else {
                string.append(character)
                state = .character
            }
        case var .hexDigits(digits):
            digits.append(character)
            if digits.count == 2 {
                state = .character
                if let scalar = Int(digits, radix: 16).flatMap(UnicodeScalar.init) {
                    string.append(Character(scalar))
                } else {
                    fatalError("Could not convert \(digits) to a Unicode Character.")
                }
            } else {
                state = .hexDigits(digits)
            }
        }
        index = code.index(after: index)
    }

    return string
}

fileprivate enum ParseState {
    case character
    case escaping
    case hexDigits(String)
}

fileprivate func encode<S: StringProtocol>(_ string: S) -> String {
    var code = "\""
    for character in string {
        if character == "\\" {
            code += "\\\\"
        } else if character == "\"" {
            code += "\\\""
        } else if character.unicodeScalars.count == 1, let scalar = character.unicodeScalars.first, scalar.value > 127 {
            code += String(format: "\\x%02x", scalar.value)
        } else {
            code.append(character)
        }
    }
    code += "\""
    return code
}
