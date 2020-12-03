//
//  day09.swift
//  AOC2015
//
//  Created by Arthur Dexter on 11/20/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import Foundation

func day09() throws {
    let distances: [CityPair: Int] = Dictionary(
        uniqueKeysWithValues: try readInput(day: 9).lines.map(parseDistance(from:)))
    let cities: Set<String> = Set(distances.keys.flatMap { [$0.city0, $0.city1] })

    let paths: [[String]] = visit(cities)
    let costs: [Int] = paths.map { path in
        (1..<path.count)
            .compactMap { distances[CityPair(path[$0 - 1], path[$0])] }
            .reduce(0, +)
    }
    guard let shortestDistance = costs.min() else {
        throw NSError(domain: "day09", code: 0, userInfo: nil)
    }
    guard let longestDistance = costs.max() else {
        throw NSError(domain: "day09", code: 0, userInfo: nil)
    }

    print("Day 09, part 01: distance=\(shortestDistance)")
    print("Day 09, part 02: distance=\(longestDistance)")
}

fileprivate func visit(_ cities: Set<String>, _ path: [String] = []) -> [[String]] {
    if cities.isEmpty {
        return [path]
    } else {
        return cities.flatMap { city -> [[String]] in
            let remainingCities = cities.symmetricDifference([city])
            return visit(remainingCities, path + [city])
        }
    }
}

fileprivate func parseDistance<S: StringProtocol>(from string: S) throws -> (CityPair, Int) {
    let tokens = string.split(separator: " ")
    guard tokens.count == 5 else {
        throw NSError(domain: "day09", code: 0, userInfo: nil)
    }
    let distance: Int = try Int(tokens[4])
    return (CityPair(tokens[0], tokens[2]), distance)
}

fileprivate struct CityPair: Hashable {
    let city0: String
    let city1: String

    init<S: StringProtocol>(_ city0: S, _ city1: S) {
        self.city0 = String(min(city0, city1))
        self.city1 = String(max(city0, city1))
    }
}
