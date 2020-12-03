//
//  day01.swift
//  AOC2015
//
//  Created by Arthur Dexter on 11/19/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import Foundation

func day01() throws {
    let input = try readInput(day: 1)

    var level: Int = 0
    var basementPosition: Int?
    for (instructionIndex, instruction) in input.enumerated() {
        switch instruction {
        case "(":
            level += 1
        case ")":
            level -= 1
        default:
            break
        }
        if basementPosition == nil, level < 0 {
            basementPosition = instructionIndex + 1
        }
    }

    print("Day 01, Part 01: Final level=\(level)")
    print("Day 01, Part 02: Basement instruction position=\(basementPosition ?? -1)")
}
