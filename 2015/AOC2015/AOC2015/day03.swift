//
//  day03.swift
//  AOC2015
//
//  Created by Arthur Dexter on 11/19/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import Foundation

func day03() throws {
    let input = try readInput(day: 3)

    var visited = Set<Coordinate>()

    var coordinate = Coordinate(x: 0, y: 0)
    visited.insert(coordinate)

    for direction in input {
        coordinate.move(direction)
        visited.insert(coordinate)
    }

    print("Day 03, part 01: Visited \(visited.count) houses.")

    var santaCoordinate = Coordinate(x: 0, y: 0)
    var roboCoordinate = Coordinate(x: 0, y: 0)

    visited = Set<Coordinate>()
    visited.insert(santaCoordinate)
    visited.insert(roboCoordinate)

    for (index, direction) in input.enumerated() {
        if index % 2 == 0 {
            santaCoordinate.move(direction)
            visited.insert(santaCoordinate)

        } else {
            roboCoordinate.move(direction)
            visited.insert(roboCoordinate)
        }
    }

    print("Day 03, part 02: Visited \(visited.count) houses.")
}

fileprivate struct Coordinate: Hashable {
    var x: Int
    var y: Int

    mutating func move(_ direction: Character) {
        switch direction {
        case "^":
            y += 1
        case "v":
            y -= 1
        case "<":
            x -= 1
        case ">":
            x += 1
        default:
            break
        }
    }
}
