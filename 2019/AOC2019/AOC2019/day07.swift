//
//  day07.swift
//  AOC2019
//
//  Created by Arthur Dexter on 12/7/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import AdventOfCodeUtils
import Foundation

func day07() throws {
    let code = try parseIntcode(from: try readInput())
    let numberOfAmplifiers = 5

    let part1PhaseCombinations: [[Int]] = choose(from: Array(0..<numberOfAmplifiers))
    let part1OutputSignals: [(output: Int, settings: [Int])] = try part1PhaseCombinations.map { phaseSettings in
        (try computeFinalOutputSignal(code: code, phaseSettings: phaseSettings), phaseSettings)
    }.sorted { (lhs, rhs) -> Bool in
        lhs.output < rhs.output
    }
    let part1BestOutputSignal = try part1OutputSignals.last.required()
    print("Day 07, part 01: Highest output signal=\(part1BestOutputSignal.output) settings=\(part1BestOutputSignal.settings)")

    let part2PhaseCombinations: [[Int]] = choose(from: Array(5..<(5+numberOfAmplifiers)))
    let part2OutputSignals: [(output: Int, settings: [Int])] = try part2PhaseCombinations.map { phaseSettings in
        (try computeFinalOutputSignalWithFeedback(code: code, phaseSettings: phaseSettings), phaseSettings)
    }.sorted { (lhs, rhs) -> Bool in
        lhs.output < rhs.output
    }
    let part2BestOutputSignal = try part2OutputSignals.last.required()
    print("Day 07, part 02: Highest output signal=\(part2BestOutputSignal.output) settings=\(part2BestOutputSignal.settings)")
}

private func computeFinalOutputSignalWithFeedback(code: [Int], phaseSettings: [Int]) throws -> Int {
    let processors = phaseSettings.map { setting in
        Processor(memory: code, input: [setting])
    }

    var previousOutput: Int? = 0
    var finalStageOutput: Int?
    repeat {
        for (index, processor) in processors.enumerated() {
            if let previousOutput = previousOutput {
                processor.sendInput(previousOutput)
            }
            previousOutput = nil

            if processor.canStep {
                processor.step()
                previousOutput = processor.popLastOutput()
                if let previousOutput = previousOutput {
                    if index == processors.count - 1 {
                        finalStageOutput = previousOutput
                    }
                }
            }
        }
    } while processors.contains(where: { $0.canStep })

    return try finalStageOutput.required()
}


private func computeFinalOutputSignal(code: [Int], phaseSettings: [Int]) throws -> Int {
    return try phaseSettings.reduce(0) { (previousOutput, phaseSetting) -> Int in
        try computeOutputSignal(
            code: code,
            phaseSetting: phaseSetting,
            inputSignal: previousOutput)
    }
}

private func computeOutputSignal(code: [Int], phaseSetting: Int, inputSignal: Int) throws -> Int {
    let processor = Processor(memory: code, input: [phaseSetting, inputSignal])
    while processor.canStep, processor.output.isEmpty {
        processor.step()
    }
    return try processor.output.first.required()
}

private func choose(from set: [Int]) -> [[Int]] {
    func doChoose(set: [Int], path: [Int], result: inout [[Int]]) {
        if !set.isEmpty {
            for (index, value) in set.enumerated() {
                var setWithoutValue = set
                setWithoutValue.remove(at: index)
                doChoose(set: setWithoutValue, path: path + [value], result: &result)
            }
        } else {
            result.append(path)
        }
    }

    var result: [[Int]] = []
    doChoose(set: set, path: [], result: &result)
    return result
}

private func parseIntcode(from string: String) throws -> [Int] {
    return try string
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .split(separator: ",")
        .map { try Int.parse($0) }
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

    func sendInput(_ input: Int) {
        self.input.append(input)
    }

    func popLastOutput() -> Int? {
        return output.popLast()
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
            if input.isEmpty {
                // Back up and try again
                instructionPointer -= instruction.length
            } else {
                let dstPointer = readParameterValue(at: 0, mode: dstMode)
                writeMemory(at: dstPointer, with: input.removeFirst())
            }
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
}
