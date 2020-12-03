//
//  day13.swift
//  AOC2019
//
//  Created by Arthur Dexter on 12/13/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import AdventOfCodeUtils
import Foundation

func day13() throws {
    var part1Tiles: [Position: Tile] = [:]
    _ = try runGame(
        joystick: { fatalError() },
        draw: { part1Tiles[$0] = $1 },
        score: { _ in })
    let numberOfBlocks = part1Tiles.values.filter { $0 == .block }.count
    print("Day 13, part 01: Number of blocks=\(numberOfBlocks)")

    // 35x23 experimentally derived
    var part2Tiles: [[Tile]] = Array(repeating: Array(repeating: .empty, count: 35), count: 23)
    var part2Score = 0

    var ballPosition = Position(x: 0, y: 0)
    var paddlePosition = Position(x: 0, y: 0)

    func display() {
        for (y, row) in part2Tiles.enumerated() {
            for (x, tile) in row.enumerated() {
                switch tile {
                case .horizontalPaddle:
                    paddlePosition = Position(x: x, y: y)
                case .ball:
                    ballPosition = Position(x: x, y: y)
                case .empty, .wall, .block:
                    break
                }
            }
        }

//        print("\u{001B}[2J") // clear screen in Terminal
//        print("\(part2Score)\n")
//        print(format(part2Tiles))
    }

    _ = try runGame(
        numberOfQuarters: 2,
        joystick: {
            if paddlePosition.x > ballPosition.x {
                return .left
            } else if paddlePosition.x < ballPosition.x {
                return .right
            } else {
                return .neutral
            }
        },
        draw: {
            part2Tiles[$0.y][$0.x] = $1
            display()
        },
        score: {
            part2Score = $0
            display()
        })
    print("Day 13, part 02: Final score=\(part2Score)")
}

private func format(_ tiles: [[Tile]]) -> String {
    return tiles.map { row in
        row.map { tile in
            switch tile {
            case .empty:
                return " "
            case .wall:
                return "|"
            case .block:
                return "█"
            case .horizontalPaddle:
                return "="
            case .ball:
                return "O"
            }
        }.joined()
    }.joined(separator: "\n")
}

private func runGame(numberOfQuarters: Int? = nil, joystick: @escaping () -> Joystick, draw: @escaping (Position, Tile) -> Void, score: @escaping (Int) -> Void) throws {
    var code = try Processor.parseIntcode(from: readInput())
    if let numberOfQuarters = numberOfQuarters {
        code[0] = numberOfQuarters
    }

    var outputBuffer: [Int] = []
    let processor = Processor(
        memory: code,
        input: { joystick().rawValue },
        output: { outputBuffer.append($0) })

    while processor.canStep {
        processor.step()
        if outputBuffer.count == 3 {
            let position = Position(x: outputBuffer[0], y: outputBuffer[1])
            if position.x == -1, position.y == 0 {
                score(outputBuffer[2])
            } else {
                let tile = try Tile(rawValue: outputBuffer[2]).required()
                draw(position, tile)
            }
            outputBuffer.removeAll(keepingCapacity: true)
        }
    }
}

private enum Joystick: Int {
    case neutral = 0
    case left = -1
    case right = 1
}

private enum Tile: Int {
    case empty
    case wall
    case block
    case horizontalPaddle
    case ball
}

private struct Position: Hashable {
    let x: Int
    let y: Int
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
