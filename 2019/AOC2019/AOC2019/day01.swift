//
//  day01.swift
//  AOC2019
//
//  Created by Arthur Dexter on 12/2/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import AdventOfCodeUtils
import Foundation

func day01() throws {
    let moduleMass: [Int] = try readInput()
        .lines
        .map { try Int.parse($0) }
    let moduleFuel = moduleMass.map(calculateFuel(mass:))

    let part1TotalFuel = moduleFuel.reduce(0, +)
    print("Day 01, part 01: Total fuel=\(part1TotalFuel)")

    var part2TotalFuel = 0
    var fuelIncrement = moduleFuel
    while !fuelIncrement.isEmpty {
        part2TotalFuel += fuelIncrement.reduce(0, +)
        fuelIncrement = fuelIncrement
            .map(calculateFuel(mass:))
            .filter { $0 > 0 }
    }
    print("Day 01, part 02: Total fuel=\(part2TotalFuel)")
}

private func calculateFuel(mass: Int) -> Int {
    return (mass / 3) - 2
}
