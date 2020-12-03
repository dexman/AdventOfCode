//
//  day24.swift
//  AOC2015
//
//  Created by Arthur Dexter on 11/25/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import Foundation

func day24() throws {
    let weights: [Int] = try readInput(day: 24).lines.map { try Int($0) }

    let part1MinimumQE = balance(weights: weights, numberOfCompartments: 3)
    print("Day 24, part 01: Minimum QE for 3 compartments=\(part1MinimumQE)")

    let part2MinimumQE = balance(weights: weights, numberOfCompartments: 4)
    print("Day 24, part 01: Minimum QE for 4 compartments=\(part2MinimumQE)")
}


private func balance(weights: [Int], numberOfCompartments: Int) -> Int {
    let totalWeight = weights.reduce(0, +)
    let weightPerCompartment = totalWeight / numberOfCompartments

    let combinations = weights.combinationsFiltered { $0.reduce(0, +) == weightPerCompartment }

    let minimumNumberOfPackages = combinations.map { $0.count }.min() ?? Int.max

    let firstCompartmentCandidateCombinations = combinations.filter { $0.count == minimumNumberOfPackages }

    return firstCompartmentCandidateCombinations.map { $0.reduce(1, *) }.min() ?? Int.max
}
