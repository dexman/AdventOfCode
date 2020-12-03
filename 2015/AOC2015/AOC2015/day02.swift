//
//  day02.swift
//  AOC2015
//
//  Created by Arthur Dexter on 11/19/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import Foundation

func day02() throws {
    let input = try readInput(day: 2)

    let presentsDimensions: [(l: Int, w: Int, h: Int)] = try input
        .lines
        .map { (line: String.SubSequence) -> (l: Int, w: Int, h: Int) in
            let dimensions = try line
                .split(separator: "x")
                .map { try Int($0) }
            assert(dimensions.count == 3)
            return (dimensions[0], dimensions[1], dimensions[2])
        }

    let totalArea = presentsDimensions.map { dimensions -> Int in
        let side0 = dimensions.l * dimensions.w
        let side1 = dimensions.l * dimensions.h
        let side2 = dimensions.w * dimensions.h
        let smallestSide = min(side0, side1, side2)
        return 2 * side0 + 2 * side1 + 2 * side2 + smallestSide
    }.reduce(0, +)

    let totalLength = presentsDimensions.map { dimensions -> Int in
        let length0 = dimensions.l + dimensions.w
        let length1 = dimensions.l + dimensions.h
        let length2 = dimensions.w + dimensions.h
        let smallestLength = min(length0, length1, length2)
        let volume = dimensions.l * dimensions.w * dimensions.h
        return smallestLength * 2 + volume
    }.reduce(0, +)

    print("Day 02, part 01: Total area=\(totalArea)")
    print("Day 02, part 02: Total length=\(totalLength)")
}
