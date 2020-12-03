//
//  day08.swift
//  AOC2019
//
//  Created by Arthur Dexter on 12/7/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import AdventOfCodeUtils
import Foundation

func day08() throws {
    let (width, height) = (25, 6)
    let layers = try parseImageLayers(from: readInput(), width: width, height: height)

    let layerWithFewestZeros = try layers.min { (lhs, rhs) -> Bool in
        numberOfDigits(equalTo: 0, in: lhs) < numberOfDigits(equalTo: 0, in: rhs)
    }.required()
    let part1Result = numberOfDigits(equalTo: 1, in: layerWithFewestZeros) * numberOfDigits(equalTo: 2, in: layerWithFewestZeros)
    print("Day 08, part 01: Result=\(part1Result)")

    let flattenedImage = flatten(layers: layers, width: width, height: height)
    print("Day 08, part 02: Image=\n\(format(image: flattenedImage))")
}

private func format(image: [[Int]]) -> String {
    return image
        .map { row in row.map { $0 == 0 ? "█" : " " }.joined() }
        .joined(separator: "\n")
}

private func flatten(layers: [[[Int]]], width: Int, height: Int) -> [[Int]] {
    var result: [[Int]] = Array(
        repeating: Array(repeating: 2, count: width),
        count: height)
    for y in 0..<height {
        for x in 0..<width {
            for layer in layers {
                let layerPixel = layer[y][x]
                if layerPixel != 2 {
                    result[y][x] = layerPixel
                    break
                }
            }
        }
    }
    assert(numberOfDigits(equalTo: 2, in: result) == 0)
    return result
}

private func numberOfDigits(equalTo digit: Int, in layer: [[Int]]) -> Int {
    return layer
        .map { row in row.filter { $0 == digit }.count }
        .reduce(0, +)
}

private func parseImageLayers(from string: String, width: Int, height: Int) throws -> [[[Int]]] {
    let digits: [Int] = try string
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .map { try Int.parse(String($0)) }

    var layers: [[[Int]]] = []
    var currentLayer: [[Int]] = []
    var currentRow: [Int] = []
    for digit in digits {
        currentRow.append(digit)
        if currentRow.count == width {
            currentLayer.append(currentRow)
            currentRow.removeAll(keepingCapacity: true)
        }
        if currentLayer.count == height {
            layers.append(currentLayer)
            currentLayer.removeAll(keepingCapacity: true)
        }
    }
    assert(currentRow.isEmpty)
    assert(currentLayer.isEmpty)
    return layers
}

