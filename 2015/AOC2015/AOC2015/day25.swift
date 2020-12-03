//
//  day25.swift
//  AOC2015
//
//  Created by Arthur Dexter on 11/25/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import Foundation

func day25() throws {
    var numbers: [[Int]] = Array(
        repeating: Array(repeating: -1, count: 3083 * 2),
        count: 3083 * 2)

    var point = Point(x: 0, y: 0)
    numbers[point.y][point.x] = 20151125

    var value: Int?
    while value == nil {
        let previousValue = numbers[point.y][point.x]
        point = point.next
        if point.y >= numbers.count || point.x >= numbers.count {
            break
        }
        numbers[point.y][point.x] = (previousValue * 252533) % 33554393
        if point.y == 2977, point.x == 3082 {
            value = numbers[point.y][point.x]
        }
    }

    guard let part1Value = value else {
        throw NSError(domain: "day25", code: 0, userInfo: nil)
    }
    print("Day 25, part 01: value at 2978,3083=\(part1Value)")
}

private struct Point {
    let x: Int
    let y: Int

    var previous: Point {
        if x > 0 {
            return Point(
                x: x - 1,
                y: y + 1)
        } else {
            return Point(
                x: y - 1,
                y: 0)
        }
    }

    var next: Point {
        if y > 0 {
            return Point(
                x: x + 1,
                y: y - 1)
        } else {
            return Point(
                x: 0,
                y: x + 1)
        }
    }
}
