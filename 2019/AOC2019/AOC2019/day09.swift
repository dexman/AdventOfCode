//
//  day09.swift
//  AOC2019
//
//  Created by Arthur Dexter on 12/8/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import AdventOfCodeUtils
import Foundation

func day09() throws {
    let code = try Processor.parseIntcode(from: readInput())

    let p = Processor(
        memory: code,
        input: [1])
    while p.canStep {
        p.step()
    }
    print("Day 09, part 01: BOOST keycode=\(p.output[0])")

    let p2 = Processor(
        memory: code,
        input: [2])
    while p2.canStep {
        p2.step()
    }
    print("Day 09, part 01: Distress coordinates=\(p2.output[0])")
}

private class Processor {

    static func parseIntcode(from string: String) throws -> [Int] {
        return try string
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: ",")
            .map { try Int.parse($0) }
    }

    init(memory: [Int], input: [Int]) {
        self.memory = memory
        self.input = input
        self.output = []
        self.instructionPointer = 0
        self.relativeBase = 0
    }

    private(set) var output: [Int]
    private(set) var memory: [Int]

    var canStep: Bool {
        return instructionPointer >= 0 && instructionPointer < memory.count
    }

    func sendInput(_ input: Int) {
        self.input.append(input)
    }

    func popLastOutput() -> Int? {
        return output.popLast()
    }

    func step() {//48
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
            if input.isEmpty {
                // Back up and try again
                instructionPointer -= instruction.length
            } else {
                let dstPointer = parameterValuePointer(at: 0, mode: dstMode)
                writeMemory(at: dstPointer, with: input.removeFirst())
            }
        case let .output(srcMode):
            let srcValue = readParameterValue(at: 0, mode: srcMode)
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

    private var input: [Int]
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
