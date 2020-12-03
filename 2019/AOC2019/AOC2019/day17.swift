//
//  day17.swift
//  AOC2019
//
//  Created by Arthur Dexter on 12/17/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import AdventOfCodeUtils
import Foundation

func day17() throws {
    let intersections = try part1()
    try part2(intersections)
}

// R 10
// R 4


private func part2(_ intersections: [Position]) throws {
    var code = try Processor.parseIntcode(from: readInput())
    code[0] = 2

    let input: String = [
//   Main====================
        "A,A,B,C,B,C,B,A,C,A",
//      A====================
        "R,8,L,12,R,8",
//      B====================
        "L,10,L,10,R,8",
//      C====================
        "L,12,L,12,L,10,R,10",
        "y\n"
    ].joined(separator: "\n")
    var inputBuffer: [Int] = input.utf8.map { Int($0) }
    var visited = Set<Position>()

    var outputBuffer: [Int] = []
    let processor = Processor(
        memory: code,
        input: { inputBuffer.removeFirst() },
        output: { outputBuffer.append($0) })
    while processor.canStep {
        processor.step()

        if outputBuffer.count > 1, outputBuffer[outputBuffer.count - 1] == 10, outputBuffer[outputBuffer.count - 2] == 10 {
            let output = String(
                outputBuffer[0..<outputBuffer.count - 2]
                .compactMap(Unicode.Scalar.init(_:))
                .map(Character.init(_:)))
            outputBuffer.removeAll(keepingCapacity: true)

            let tiles: [[Character]] = output
                .map { $0 }
                .split(separator: "\n")
                .map { Array($0) }
            for (y, row) in tiles.enumerated() {
                for (x, tile) in row.enumerated() {
                    if tile == ">" || tile == "<" || tile == "v" || tile == "^" {
                        visited.insert(Position(x: x, y: y))
                    }
                }
            }

            let remaining = intersections.filter({ !visited.contains($0) })
            print(String(mark(remaining, in: tiles)))
            print("remaining=\(remaining.count)")
            print()
        }
    }

    let output = String(outputBuffer
        .compactMap(Unicode.Scalar.init(_:))
        .map(Character.init(_:)))
    print(output)
}

private func part1() throws -> [Position] {
    let code = try Processor.parseIntcode(from: readInput())

    var outputBuffer: [Int] = []
    let processor = Processor(
        memory: code,
        input: { fatalError() },
        output: { outputBuffer.append($0) })
    while processor.canStep { processor.step() }

    let rows: [[Character]] = outputBuffer
        .compactMap(Unicode.Scalar.init(_:))
        .map(Character.init(_:))
        .split(separator: "\n")
        .map { Array($0) }
    let intersections = findIntersections(in: rows)

    let part1Result = intersections.map { $0.alignmentParameter }.reduce(0, +)
    print("Day 17, part 02: Sum of alignment parameters=\(part1Result)")

    print(String(mark(intersections, in: rows)))

    return intersections
}

private extension String {

    init(_ rows: [[Character]]) {
        self.init(rows.joined(separator: "\n"))
    }
}

private func mark(_ intersections: [Position], in rows: [[Character]]) -> [[Character]] {
    let set = Set(intersections)
    return rows.enumerated().map { rowArg in
        let (y, row) = rowArg
        return row.enumerated().map { arg in
            let (x, tile) = arg
            if set.contains(Position(x: x, y: y)) {
                return "O"
            } else {
                return tile
            }
        }
    }
}

private func findIntersections(in rows: [[Character]]) -> [Position] {
    var intersections: [Position] = []
    for (y, row) in rows.enumerated() {
        for (x, tile) in row.enumerated() {
            // Ensure we are on a scaffolding position
            guard tile == "#" else { continue }

            let leftTilePresent = x > 0 && row[x - 1] == "#"
            let rightTilePresent = x < row.count - 1 && row[x + 1] == "#"
            let topTilePresent = y > 0 && rows[y - 1][x] == "#"
            let bottomTilePresent = y < rows.count - 1 && rows[y + 1][x] == "#"

            let isIntersection =
                ((leftTilePresent && rightTilePresent) && (topTilePresent || bottomTilePresent)) ||
                ((topTilePresent && bottomTilePresent) && (leftTilePresent || rightTilePresent))
            if isIntersection {
                intersections.append(Position(x: x, y: y))
            }
        }
    }
    return intersections
}

private struct Position: Hashable {
    let x: Int
    let y: Int

    var alignmentParameter: Int {
        return x * y
    }
}

private class Processor {

    static func parseIntcode(from string: String) throws -> [Int] {
        return try string
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: ",")
            .map { try Int.parse($0) }
    }

    init(memory: [Int], input: @escaping () -> Int, output: @escaping (Int) -> Void) {
        self.memory = memory
        self.input = input
        self.output = output
        self.instructionPointer = 0
        self.relativeBase = 0
    }

    private(set) var memory: [Int]

    var canStep: Bool {
        return instructionPointer >= 0 && instructionPointer < memory.count
    }

    func step() {
        let instruction = decodeInstruction(at: instructionPointer)
        switch instruction {
        case let .add(srcModes, dstMode):
            let srcValues: [Int] = srcModes.enumerated().map(readParameterValue(at:mode:))
            let dstPointer = parameterValuePointer(at: srcValues.count, mode: dstMode)
            let sum = srcValues.reduce(0, +)
            writeMemory(at: dstPointer, with: sum)
        case let .multiply(srcModes, dstMode):
            let srcValues: [Int] = srcModes.enumerated().map(readParameterValue(at:mode:))
            let dstPointer = parameterValuePointer(at: srcValues.count, mode: dstMode)
            let product = srcValues.reduce(1, *)
            writeMemory(at: dstPointer, with: product)
        case let .input(dstMode):
            let inputValue = input()
            let dstPointer = parameterValuePointer(at: 0, mode: dstMode)
            writeMemory(at: dstPointer, with: inputValue)
        case let .output(srcMode):
            let srcValue = readParameterValue(at: 0, mode: srcMode)
            output(srcValue)
        case let .jumpIfTrue(src: srcMode, dst: dstMode):
            let src = readParameterValue(at: 0, mode: srcMode)
            if src != 0 {
                let dstPointer = readParameterValue(at: 1, mode: dstMode)
                instructionPointer = dstPointer - instruction.length
            }
        case let .jumpIfFalse(src: srcMode, dst: dstMode):
            let src = readParameterValue(at: 0, mode: srcMode)
            if src == 0 {
                let dstPointer = readParameterValue(at: 1, mode: dstMode)
                instructionPointer = dstPointer - instruction.length
            }
        case let .lessThan(srcModes, dstMode):
            let srcValues: [Int] = srcModes.enumerated().map(readParameterValue(at:mode:))
            let dstPointer = parameterValuePointer(at: srcValues.count, mode: dstMode)
            let dstValue = srcValues[0] < srcValues[1] ? 1 : 0
            writeMemory(at: dstPointer, with: dstValue)
        case let .equal(srcModes, dstMode):
            let srcValues: [Int] = srcModes.enumerated().map(readParameterValue(at:mode:))
            let dstPointer = parameterValuePointer(at: srcValues.count, mode: dstMode)
            let dstValue = srcValues[0] == srcValues[1] ? 1 : 0
            writeMemory(at: dstPointer, with: dstValue)
        case let .relativeBaseOffset(mode):
            relativeBase += readParameterValue(at: 0, mode: mode)
        case .halt:
            instructionPointer = memory.count - 1
        }
        instructionPointer += instruction.length
    }

    private let input: () -> Int
    private let output: (Int) -> Void
    private var instructionPointer: Int
    private var relativeBase: Int

    private func readMemory(at position: Int) -> Int {
        guard position >= 0 else {
            fatalError("Invalid memory position \(position)")
        }
        if position < memory.count {
            return memory[position]
        } else {
            return 0
        }
    }

    private func writeMemory(at position: Int, with value: Int) {
        guard position >= 0 else {
            fatalError("Invalid memory position \(position)")
        }
        if position >= memory.count {
            let itemsToAdd = [Int](repeating: 0, count: position - memory.count + 1)
            memory.append(contentsOf: itemsToAdd)
        }
        memory[position] = value
    }

    private func decodeInstruction(at position: Int) -> Opcode {
        let instruction = readMemory(at: position)

        func decodeParameterMode(at parameterIndex: Int) -> Parameter.Mode {
            let modeInstructions = instruction / 100
            guard modeInstructions > 0 else {
                return .position
            }

            let divisor = (pow(10, parameterIndex) as NSDecimalNumber).intValue
            let modeValue = (modeInstructions / divisor) % 10
            switch modeValue {
            case 0:
                return .position
            case 1:
                return .immediate
            case 2:
                return .relative
            default:
                fatalError("Invalid modeValue=\(modeValue) in instruction=\(instruction) at position=\(position)")
            }
        }

        // Decode the opcode value.
        let opcode = instruction % 100
        switch opcode {
        case 1:
            let src: [Parameter.Mode] = (0..<2).map(decodeParameterMode(at:))
            let dst = decodeParameterMode(at: 2)
            return .add(src: src, dst: dst)
        case 2:
            let src: [Parameter.Mode] = (0..<2).map(decodeParameterMode(at:))
            let dst = decodeParameterMode(at: 2)
            return .multiply(src: src, dst: dst)
        case 3:
            return .input(dst: decodeParameterMode(at: 0))
        case 4:
            return .output(src: decodeParameterMode(at: 0))
        case 5:
            return .jumpIfTrue(
                src: decodeParameterMode(at: 0),
                dst: decodeParameterMode(at: 1))
        case 6:
            return .jumpIfFalse(
                src: decodeParameterMode(at: 0),
                dst: decodeParameterMode(at: 1))
        case 7:
            let src: [Parameter.Mode] = (0..<2).map(decodeParameterMode(at:))
            let dst = decodeParameterMode(at: 2)
            return .lessThan(src: src, dst: dst)
        case 8:
            let src: [Parameter.Mode] = (0..<2).map(decodeParameterMode(at:))
            let dst = decodeParameterMode(at: 2)
            return .equal(src: src, dst: dst)
        case 9:
            return .relativeBaseOffset(decodeParameterMode(at: 0))
        case 99:
            return .halt
        default:
            fatalError("Invalid opcode=\(opcode) in instruction=\(instruction) at position=\(position)")
        }
    }

    private func parameterValuePointer(at parameterIndex: Int, mode: Parameter.Mode) -> Int {
        let offset = parameterIndex + 1
        let valuePointer: Int
        switch mode {
        case .position:
            valuePointer = readMemory(at: instructionPointer + offset)
        case .immediate:
            valuePointer = instructionPointer + offset
        case .relative:
            let valueOffset = readMemory(at: instructionPointer + offset)
            valuePointer = relativeBase + valueOffset
        }
        return valuePointer
    }

    private func readParameterValue(at parameterIndex: Int, mode: Parameter.Mode) -> Int {
        let valuePointer = parameterValuePointer(at: parameterIndex, mode: mode)
        return readMemory(at: valuePointer)
    }

    private enum Opcode {
        case add(src: [Parameter.Mode], dst: Parameter.Mode)
        case multiply(src: [Parameter.Mode], dst: Parameter.Mode)
        case input(dst: Parameter.Mode)
        case output(src: Parameter.Mode)
        case jumpIfTrue(src: Parameter.Mode, dst: Parameter.Mode)
        case jumpIfFalse(src: Parameter.Mode, dst: Parameter.Mode)
        case lessThan(src: [Parameter.Mode], dst: Parameter.Mode)
        case equal(src: [Parameter.Mode], dst: Parameter.Mode)
        case relativeBaseOffset(Parameter.Mode)
        case halt

        var length: Int {
            switch self {
            case let .add(srcModes, _), let .multiply(srcModes, _), let .lessThan(srcModes, dst: _), let .equal(srcModes, dst: _):
                return srcModes.count + 2
            case .jumpIfTrue, .jumpIfFalse:
                return 3
            case .input, .output, .relativeBaseOffset:
                return 2
            case .halt:
                return 1
            }
        }
    }

    private struct Parameter {
        enum Mode {
            case position
            case immediate
            case relative
        }

        let mode: Mode
        let value: Int
    }
}
