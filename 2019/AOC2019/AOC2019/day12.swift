//
//  day12.swift
//  AOC2019
//
//  Created by Arthur Dexter on 12/13/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import AdventOfCodeUtils
import Foundation

func day12() throws {
    let initialBodies = try parseBodies(from: readInput())

    let numberOfSteps = 1000
    var bodies = initialBodies
    var steps = 0
    while steps < numberOfSteps {
        applyGravity(to: &bodies)
        applyVelocity(to: &bodies)
        steps += 1
    }
    print("Day 12, part 01: Total energy after \(numberOfSteps) steps=\(totalEnergy(in: bodies))")

    // Find the period for each coordinate value, since the coordinates are independent
    let periods: [Int] = (0..<3).map { coordinateIndex in
        var bodies = initialBodies
        var seenCoordinateValues: Set<[Int16]> = []
        while true {
            let coordinateValues: [Int16] = bodies.flatMap { [$0.position[coordinateIndex], $0.velocity[coordinateIndex]] }
            if !seenCoordinateValues.insert(coordinateValues).inserted {
                break
            }
            applyGravity(to: &bodies)
            applyVelocity(to: &bodies)
        }
        return seenCoordinateValues.count
    }

    // The least common multiple of the periods is the total number of steps for all coordinates to repeat.
    let part2NumberOfSteps = leastCommonMultiple(of: periods)
    print("Day 12, part 02: Number of steps steps=\(part2NumberOfSteps)")
}

private func parseBodies(from string: String) throws -> [Body] {
    return try string
        .replacingOccurrences(of: ">", with: "")
        .lines
        .map { line in
            let coordinates: [Int16] = try line
                .split(separator: ", ")
                .compactMap { componentString in
                    componentString.split(separator: "=").last
                }
                .map { try Int16.parse($0) }
            guard coordinates.count == 3 else {
                throw ParseError<[Int16]>(line)
            }
            return Body(position: coordinates, velocity: [0, 0, 0])
        }
}

private func leastCommonMultiple(of values: [Int]) -> Int {
    return values.reduce(1) { (lhs, rhs) -> Int in
        return abs(lhs * rhs) / greatestCommonDivisor(lhs, rhs)
    }
}

private func totalEnergy(in bodies: [Body]) -> Int {
    return bodies.map { $0.totalEnergy }.reduce(0, +)
}

private func applyVelocity(to bodies: inout [Body]) {
    for index in bodies.indices {
        bodies[index].applyVelocity()
    }
}

private func applyGravity(to bodies: inout [Body]) {
    for bodyIndex in bodies.indices {
        var body = bodies[bodyIndex]
        for otherBodyIndex in bodies.indices {
            guard bodyIndex != otherBodyIndex else { continue }
            let otherBody = bodies[otherBodyIndex]
            for i in 0..<3 {
                if otherBody.position[i] < body.position[i] {
                    body.velocity[i] -= 1
                } else if otherBody.position[i] > body.position[i] {
                    body.velocity[i] += 1
                }
            }
        }
        bodies[bodyIndex] = body
    }
}

private struct Body: Hashable {

    var position: [Int16]
    var velocity: [Int16]

    static func applyGravity(_ lhs: inout Body, _ rhs: inout Body) {
        for i in 0..<3 {
            if lhs.position[i] != rhs.position[i] {
                let lhsLessX = lhs.position[i] < rhs.position[i]
                lhs.velocity[i] += lhsLessX ? 1 : -1
                rhs.velocity[i] += lhsLessX ? -1 : 1
            }
        }
    }

    mutating func applyVelocity() {
        for i in 0..<3 {
            position[i] = position[i] + velocity[i]
        }
    }

    var totalEnergy: Int {
        let potentialEnergy = position.map { Int(abs($0)) }.reduce(0, +)
        let kineticEnergy = velocity.map { Int(abs($0)) }.reduce(0, +)
        return potentialEnergy * kineticEnergy
    }
}
