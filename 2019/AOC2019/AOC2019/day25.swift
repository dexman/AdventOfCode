//
//  day25.swift
//  AOC2019
//
//  Created by Arthur Dexter on 12/30/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import AdventOfCodeUtils
import Foundation

func day25() throws {
    let code = try IntcodeProcessor.parseIntcode(from: readInput())

    for item in items {
        script.append("drop \(item)")
    }
    for combination in items.combinations {
        for item in combination {
            script.append("take \(item)")
        }
        script.append("inv")
        script.append("north")
        for item in combination {
            script.append("drop \(item)")
        }
    }

    var scriptIndex = 0
    var input: [Int] = []
    var output: [Character] = []
    let processor = IntcodeProcessor(
        memory: code,
        input: {
            input.removeFirst()
        }, output: {
            let outputCharacter = Character(Unicode.Scalar($0)!)
            output.append(outputCharacter)
            print(outputCharacter, terminator: "")
            if String(output).hasSuffix("Command?\n") {
                if scriptIndex < script.count {
                    input.append(contentsOf: (script[scriptIndex] + "\n").utf8.map { Int($0) })
                    scriptIndex += 1
                } else if let line = readLine(strippingNewline: false) {
                    input.append(contentsOf: line.utf8.map { Int($0) })
                }
            }
        })
    while processor.canStep { processor.step() }
}

private var script: [String] = [
    // start in 1, Hull breach
    "south", // 2, Observatory
    "east", // 3, Navigation
    "take whirled peas",
    "west", // 2, Observatory
    "north", // 1, Hull breach
    "north", // 4, Holodeck
    "east", // 5, Warp drive maint.
    "take ornament",
    "north", // 6, Kitchen
    "north", // 7, Sick bay
    "take dark matter",
    "south", // 6, Kitchen
    "south", // 5, Warp drive maint.
    "west", // 4, Holodeck
    "west", // 9, Science lab
    "west", // 10, Gift wrapping center
    "take candy cane",
    "west", // 11, Passages
    "west", // 12, Storage
    "take tambourine",
    "east", // 11 Passages
    "east", // 10, Gift wrapping center
    "east", // 9, Science lab
    "north", // 14, Crew quarters
    "take astrolabe",
    "east", // 16, Engineering
    "take hologram",
    "east", // 17, Corridor
    "take klein bottle",
    "west", // 16, Engineering
    "south", // 18, Arcade
    "west", // 19, Security checkpoint
]

private let items: [String] = [
    "ornament",
    "klein bottle",
    "dark matter",
    "candy cane",
    "hologram",
    "astrolabe",
    "whirled peas",
    "tambourine"
]

// winners:
//- klein bottle
//- hologram
//- astrolabe
//- tambourine

//== Pressure-Sensitive Floor ==
//Analyzing...
//
//Doors here lead:
//- south
//
//A loud, robotic voice says "Analysis complete! You may proceed." and you enter the cockpit.
//Santa notices your small droid, looks puzzled for a moment, realizes what has happened, and radios your ship directly.
//"Oh, hello! You should be able to get in by typing 134349952 on the keypad at the main airlock."
