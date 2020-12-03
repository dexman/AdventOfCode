//
//  day05.swift
//  AOC2019
//
//  Created by Arthur Dexter on 12/4/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import AdventOfCodeUtils
import Foundation

func day05() throws {
    let code = try parseIntcode(from: try readInput())

    let part1Output = run(code: code, input: [1])
    let part1DiagnosticCode = try part1Output.last.required()
    print("Day 05, part 01: Diagnostic code=\(part1DiagnosticCode)")

    let part2Output = run(code: code, input: [5])
    let part2DiagnosticCode = try part2Output.last.required()
    print("Day 05, part 02: Diagnostic code=\(part2DiagnosticCode)")
}

private func parseIntcode(from string: String) throws -> [Int] {
    return try string
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .split(separator: ",")
        .map { try Int.parse($0) }
}

private func run(code: [Int], input: [Int]) -> [Int] {
    let processor = Processor(memory: code, input: input)
    while processor.canStep {
        processor.step()
    }
    return processor.output
}

private class Processor {

    init(memory: [Int], input: [Int]) {
        self.memory = memory
        self.input = input
        self.output = []
        self.instructionPointer = 0
    }

    private(set) var output: [Int]
    private(set) var memory: [Int]

    var canStep: Bool {
        return instructionPointer >= 0 && instructionPointer < memory.count
    }

    func step() {
        let instruction = decodeInstruction(at: instructionPointer)
        switch instruction {
        case let .add(srcModes, dstMode):
            let srcValues: [Int] = srcModes.enumerated().map(readParameterValue(at:mode:))
            let dstPointer = readParameterValue(at: srcValues.count, mode: dstMode)
            let sum = srcValues.reduce(0, +)
            writeMemory(at: dstPointer, with: sum)
        case let .multiply(srcModes, dstMode):
            let srcValues: [Int] = srcModes.enumerated().map(readParameterValue(at:mode:))
            let dstPointer = readParameterValue(at: srcValues.count, mode: dstMode)
            let product = srcValues.reduce(1, *)
            writeMemory(at: dstPointer, with: product)
        case let .input(dstMode):
            guard !input.isEmpty else {
                fatalError("Attempt to read input when input buffer is empty")
            }
            let dstPointer = readParameterValue(at: 0, mode: dstMode)
            writeMemory(at: dstPointer, with: input.removeFirst())
        case let .output(srcMode):
            let srcPointer = readParameterValue(at: 0, mode: srcMode)
            let srcValue = readMemory(at: srcPointer)
            output.append(srcValue)
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
            let dstPointer = readParameterValue(at: srcValues.count, mode: dstMode)
            let dstValue = srcValues[0] < srcValues[1] ? 1 : 0
            writeMemory(at: dstPointer, with: dstValue)
        case let .equal(srcModes, dstMode):
            let srcValues: [Int] = srcModes.enumerated().map(readParameterValue(at:mode:))
            let dstPointer = readParameterValue(at: srcValues.count, mode: dstMode)
            let dstValue = srcValues[0] == srcValues[1] ? 1 : 0
            writeMemory(at: dstPointer, with: dstValue)
        case .halt:
            instructionPointer = memory.count - 1
        }
        instructionPointer += instruction.length
    }

    private var input: [Int]
    private var instructionPointer: Int

    private func readMemory(at position: Int) -> Int {
        guard position >= 0, position < memory.count else {
            fatalError("Invalid memory position \(position)")
        }
        return memory[position]
    }

    private func writeMemory(at position: Int, with value: Int) {
        guard position >= 0, position < memory.count else {
            fatalError("Invalid memory position \(position)")
        }
        memory[position] = value
    }

    private func decodeInstruction(at position: Int) -> Opcode {
        let instruction = readMemory(at: position)

        func decodeParameterMode(at parameterIndex: Int) -> Parameter.Mode {
            let divisor = (pow(10, (parameterIndex + 2)) as NSDecimalNumber).intValue
            let modeValue = (instruction / divisor) % 10
            switch modeValue {
            case 0:
                return .position
            case 1:
                return .immediate
            default:
                fatalError("Invalid modeValue=\(modeValue) in instruction=\(instruction) at position=\(position)")
            }
        }

        // Decode the opcode value.
        let opcode = instruction % 100
        switch opcode {
        case 1:
            let src: [Parameter.Mode] = (0..<2).map(decodeParameterMode(at:))
            return .add(src: src, dst: .immediate)
        case 2:
            let src: [Parameter.Mode] = (0..<2).map(decodeParameterMode(at:))
            return .multiply(src: src, dst: .immediate)
        case 3:
            return .input(dst: .immediate)
        case 4:
            return .output(src: .immediate)
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
            return .lessThan(src: src, dst: .immediate)
        case 8:
            let src: [Parameter.Mode] = (0..<2).map(decodeParameterMode(at:))
            return .equal(src: src, dst: .immediate)
        case 99:
            return .halt
        default:
            fatalError("Invalid opcode=\(opcode) in instruction=\(instruction) at position=\(position)")
        }
    }

    private func readParameterValue(at parameterIndex: Int, mode: Parameter.Mode) -> Int {
        let offset = parameterIndex + 1
        let valuePointer: Int
        switch mode {
        case .position:
            valuePointer = readMemory(at: instructionPointer + offset)
        case .immediate:
            valuePointer = instructionPointer + offset
        }
        return readMemory(at: valuePointer)
    }
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
    case halt

    var length: Int {
        switch self {
        case let .add(srcModes, _), let .multiply(srcModes, _), let .lessThan(srcModes, dst: _), let .equal(srcModes, dst: _):
            return srcModes.count + 2
        case .jumpIfTrue, .jumpIfFalse:
            return 3
        case .input, .output:
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
    }

    let mode: Mode
    let value: Int
}
