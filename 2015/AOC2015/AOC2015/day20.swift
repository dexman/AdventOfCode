//
//  day20.swift
//  AOC2015
//
//  Created by Arthur Dexter on 11/22/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import Foundation

func day20() throws {
    let input: Int = try Int(readInput(day: 20).trimmingCharacters(in: .whitespacesAndNewlines))

    let resultPart1 = (1...(input / 10)).first { n -> Bool in
        presentsForHousePart1(n) >= input
    } ?? -1
    print("Day 20, part 01: lowest house number=\(resultPart1)")

    let resultPart2 = (1...(input / 11)).first { n -> Bool in
        presentsForHousePart2(n) >= input
    } ?? -1
    print("Day 20, part 02: lowest house number=\(resultPart2)")
}

private func presentsForHousePart2(_ n: Int) -> Int {
    func isDelivering(elf: Int, n: Int) -> Bool {
        return Double(n) / Double(elf) <= 50
    }

    var presents = 0
    for elf in 1...Int(sqrt(Double(n))) {
        if n % elf == 0 {
            if isDelivering(elf: elf, n: n) {
                presents += elf
            }

            let otherDivisor = n / elf
            if otherDivisor != elf, isDelivering(elf: otherDivisor, n: n) {
               presents += otherDivisor
            }
        }
    }
    return presents * 11
}

private func presentsForHousePart1(_ n: Int) -> Int {
    var presents = 0
    for elf in 1...Int(sqrt(Double(n))) {
        if n % elf == 0 {
            presents += elf

            let otherDivisor = n / elf
            if otherDivisor != elf {
                presents += otherDivisor
            }
        }
    }
    return presents * 10
}
