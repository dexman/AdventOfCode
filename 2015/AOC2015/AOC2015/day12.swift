//
//  day12.swift
//  AOC2015
//
//  Created by Arthur Dexter on 11/21/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import Foundation

func day12() throws {
    let json = try JSONSerialization.jsonObject(with: readInputData(day: 12))

    var part1Sum = 0
    visitLeaves(json) {
        if let number = $0 as? NSNumber {
            part1Sum += number.intValue
        }
    }
    print("Day 12, part 01: Sum of numbers=\(part1Sum)")

    var part2Sum = 0
    visitLeaves(json, filter: {
        guard let dictionary = $0 as? NSDictionary else {
            return true
        }
        let containsRed = dictionary.allValues.contains { value in
            return (value as? NSString) == "red"
        }
        return !containsRed
    }, visit: {
        if let number = $0 as? NSNumber {
            part2Sum += number.intValue
        }
    })
    print("Day 12, part 02: Sum of numbers=\(part2Sum)")
}

fileprivate func visitLeaves(_ json: Any, filter: (Any) -> Bool = { _ in true }, visit: (Any) -> Void) {
    if !filter(json) {
        return
    }

    switch json {
    case let dictionary as NSDictionary:
        for value in dictionary.allValues {
            visitLeaves(value, filter: filter, visit: visit)
        }
    case let array as NSArray:
        for value in array {
            visitLeaves(value, filter: filter, visit: visit)
        }
    default:
        // NSString, NSNumber, NSArray, NSDictionary, or NSNull.
        visit(json)
    }
}
