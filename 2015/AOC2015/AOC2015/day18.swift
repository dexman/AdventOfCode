//
//  day18.swift
//  AOC2015
//
//  Created by Arthur Dexter on 11/22/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import Foundation

func day18() throws {
    let initialConfigurationPart1 = try readInput(day: 18).lines.map(parseLine(from:))

    let finalConfigurationPart1 = (0..<100).reduce(initialConfigurationPart1) { (configuration, _) in
        animationStep(configuration: configuration, cornersStuck: false)
    }

    let numberOfLightsOnPart1 = finalConfigurationPart1.reduce(0) { (totalSum, row) in
        row.reduce(totalSum) { (sum, light) in sum + (light ? 1 : 0) }
    }
    print("Day 18, part 01: Number of lights on=\(numberOfLightsOnPart1)")

    var initialConfigurationPart2 = initialConfigurationPart1
    setCorners(of: &initialConfigurationPart2, to: true)

    let finalConfigurationPart2 = (0..<100).reduce(initialConfigurationPart2) { (configuration, _) in
        animationStep(configuration: configuration, cornersStuck: true)
    }

    let numberOfLightsOnPart2 = finalConfigurationPart2.reduce(0) { (totalSum, row) in
        row.reduce(totalSum) { (sum, light) in sum + (light ? 1 : 0) }
    }
    print("Day 18, part 02: Number of lights on=\(numberOfLightsOnPart2)")
}

private func setCorners(of configuration: inout [[Bool]], to: Bool) {
    guard
        configuration.count > 0,
        configuration[0].count > 0
    else {
        return
    }

    configuration[0][0] = true
    configuration[0][configuration[0].count - 1] = true
    configuration[configuration.count - 1][0] = true
    configuration[configuration.count - 1][configuration[0].count - 1] = true
}

private func animationStep(configuration: [[Bool]], cornersStuck: Bool) -> [[Bool]] {
    var nextConfiguration = configuration
    for y in 0..<configuration.count {
        for x in 0..<configuration[y].count {
            let numberOfOnNeighbors = countNeighborsOn(x: x, y: y, in: configuration)
            if configuration[y][x] {
                // A light which is on stays on when 2 or 3 neighbors are on, and turns off otherwise.
                nextConfiguration[y][x] = numberOfOnNeighbors == 2 || numberOfOnNeighbors == 3
            } else {
                // A light which is off turns on if exactly 3 neighbors are on, and stays off otherwise.
                nextConfiguration[y][x] = numberOfOnNeighbors == 3
            }
        }
    }

    if cornersStuck {
        setCorners(of: &nextConfiguration, to: true)
    }

    return nextConfiguration
}

private func countNeighborsOn(x: Int, y: Int, in configuration: [[Bool]]) -> Int {
    var numberOfOnNeighbors = 0
    for neighborY in (y - 1)...(y + 1) {
        for neighborX in (x - 1)...(x + 1) {
            if
                neighborY >= 0, neighborY < configuration.count,
                neighborX >= 0, neighborX < configuration[neighborY].count,
                (neighborX != x || neighborY != y),
                configuration[neighborY][neighborX]
            {
                numberOfOnNeighbors += 1
            }
        }
    }
    return numberOfOnNeighbors
}

private func parseLine<S: StringProtocol>(from s: S) -> [Bool] {
    return s.map { $0 == "#" }
}

private func format(configuration: [[Bool]]) -> String {
    return configuration.map { row in
        row.map { $0 ? "#" : "." }.joined()
    }.joined(separator: "\n") + "\n"
}
