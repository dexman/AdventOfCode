//
//  day06.swift
//  AOC2019
//
//  Created by Arthur Dexter on 12/6/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import AdventOfCodeUtils
import Foundation

func day06() throws {
    let orbits = parseOrbits(from: try readInput())

    let allPlanets: Set<String> = Set(Array(orbits.values) + Array(orbits.keys))
    let totalOrbits = allPlanets
        .map { planet in
            var current = planet
            var total = 0
            while let next = orbits[current] {
                total += 1
                current = next
            }
            return total
        }
        .reduce(0, +)
    print("Day 06, part 01: Total number of orbits is: \(totalOrbits)")

    let source = try orbits["YOU"].required()
    let destination = try orbits["SAN"].required()

    var orbitedBy: [String: [String]] = [:]
    for planet in allPlanets {
        for (orbiting, orbited) in orbits {
            if orbited == planet {
                orbitedBy[planet, default: []].append(orbiting)
            }
        }
    }

    let shortestPath = aStar(
        start: source,
        goal: destination,
        distance: { _, _ in 1 },
        heuristicDistance: { _ in 0 },
        neighbors: {
            var neighbors = Set<String>()
            if let orbiting = orbits[$0] {
                neighbors.insert(orbiting)
            }
            neighbors.formUnion(orbitedBy[$0, default: []])
            return neighbors
        })
    let numberOfTransfers = (try shortestPath.required()).count - 1
    print("Day 06, part 02: Number of transfers=\(numberOfTransfers)")
}

private func parseOrbits(from string: String) -> [String: String] {
    let orbitPairs: [(String, String)] = string
        .lines
        .map { $0.split(separator: ")") }
        .map { (String($0[1]), String($0[0])) }
    return Dictionary(uniqueKeysWithValues: orbitPairs)
}
