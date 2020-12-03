//
//  day17.swift
//  AOC2015
//
//  Created by Arthur Dexter on 11/21/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import Foundation

func day17() throws {
    let containers: [Int] = try readInput(day: 17).lines.map { try Int($0) }

    let containerCombinations = combinations(containers: containers, amount: 150)
    print("Day 17, part 01: Number of combinations=\(containerCombinations.count)")

    let minimumNumberOfContainers = containerCombinations.map({ $0.count }).min()
    let minimalContainerCombinations = containerCombinations.filter { $0.count == minimumNumberOfContainers }
    print("Day 17, part 02: Number of combinations=\(minimalContainerCombinations.count)")
}

private func combinations(containers: [Int], amount: Int) -> [[Int]] {
    guard !containers.isEmpty, amount > 0 else {
        return []
    }

    // Generate all possible combinations of container indexes
    let n = containers.count
    let combinationIndexes = (0..<(1 << n)).map { $0.indexesOfSetBits }

    // Convert from indexes to actual amounts
    let combinations: [[Int]] = combinationIndexes.map { indexes in
        indexes.map { containers[$0] }
    }

    // Filter combinations by those that hold exactly amount
    return combinations.filter { combination in
        combination.reduce(0, +) == amount
    }
}
