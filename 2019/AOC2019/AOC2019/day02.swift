//
//  day02.swift
//  AOC2019
//
//  Created by Arthur Dexter on 12/2/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import AdventOfCodeUtils
import Foundation

func day02() throws {
    let code: [Int] = try readInput()
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .split(separator: ",")
        .map { try Int.parse($0) }

    let part1Answer = run(noun: 12, verb: 2, code: code)
    print("Day 02, part 01, value of position 0=\(part1Answer)")

    let inputCombinations = choose(sets: [Array((0...99)), Array((0...99))])
    let successfulInputs = inputCombinations.filter({ run(noun: $0[0], verb: $0[1], code: code) == 19690720 })
    let part2Inputs = try successfulInputs.first.required()
    let part2Answer = 100 * part2Inputs[0] + part2Inputs[1]
    print("Day 02, part 02, answer=\(part2Answer)")
}

private func choose(sets: [[Int]]) -> [[Int]] {
    func doChoose(sets: [[Int]], path: [Int], result: inout [[Int]]) {
        if let set = sets.last {
            for item in set {
                doChoose(sets: sets.dropLast(), path: path + [item], result: &result)
            }
        } else {
            result.append(path)
        }
    }

    var result: [[Int]] = []
    doChoose(sets: sets, path: [], result: &result)
    return result
}

private func run(noun: Int, verb: Int, code: [Int]) -> Int {
    let processor = Processor(code)
    processor.write(position: 1, value: noun)
    processor.write(position: 2, value: verb)
    while processor.canStep {
        processor.step()
    }
    return processor.read(position: 0)
}

private class Processor {
    init(_ code: [Int]) {
        self.code = code
        self.instructionPointer = 0
    }

    var canStep: Bool {
        return instructionPointer >= 0 && instructionPointer < code.count
    }

    func step() {
        guard canStep else { return }

        let opcode = code[instructionPointer]
        assert([1, 2, 99].contains(opcode))
        switch opcode {
        case 1:
            assert(instructionPointer + 3 < code.count, "Not enough arguments for opcode \(opcode) at position \(instructionPointer)")
            let sum = read(position: code[instructionPointer + 1]) + read(position: code[instructionPointer + 2])
            write(position: code[instructionPointer + 3], value: sum)
            instructionPointer += 4
        case 2:
            assert(instructionPointer + 3 < code.count, "Not enough arguments for opcode \(opcode) at position \(instructionPointer)")
            let product = read(position: code[instructionPointer + 1]) * read(position: code[instructionPointer + 2])
            write(position: code[instructionPointer + 3], value: product)
            instructionPointer += 4
        case 99:
            instructionPointer = code.count
        default:
            assert(false, "Invalid opcode=\(opcode) at position \(instructionPointer)")
        }
    }

    var code: [Int]
    private var instructionPointer: Int

    func read(position: Int) -> Int {
        assert(position >= 0)
        assert(position < code.count)
        return code[position]
    }

    func write(position: Int, value: Int) {
        assert(position >= 0)
        assert(position < code.count)
        code[position] = value
    }
}
