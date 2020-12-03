//
//  day19.swift
//  AOC2019
//
//  Created by Arthur Dexter on 12/19/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import AdventOfCodeUtils
import Foundation

func day19() throws {
    let code = try Processor.parseIntcode(from: readInput())

    let area: (width: Int, height: Int) = (50, 50)
    let effectiveRangeXs = (0..<area.height).map { y in tractorEffectiveRangeX(at: y, code: code) }
    let totalEffective = effectiveRangeXs.reduce(0) { $0 + $1.clamped(to: 0..<area.width).count }
    print("Day 19, part 01: Total effective area=\(totalEffective)")//234

    let shipSize: (width: Int, height: Int) = (100, 100)
    // Find y coordinate by binary search over widths that fit.
    var (firstY, lastY) = (0, 1000)
    var it = 0
    var count = lastY - firstY
    var step = 0
    while count > 0 {
        it = firstY
        step = count / 2
        it += step
        if shipWidthThatFits(at: it, shipHeight: shipSize.height, code: code) < shipSize.width {
            it += 1
            firstY = it
            count -= step + 1
        } else {
            count = step
        }
    }
    let firstX = tractorEffectiveRangeX(at: firstY + shipSize.height - 1, code: code).lowerBound

    let part2Result = firstX * 10000 + firstY
    print("Day 19, part 02: Value that fits ship is=\(part2Result)")//9290812
}

private func formatTractor(_ effectiveRangeXs: [Range<Int>]) -> String {
    let width = effectiveRangeXs.map { $0.upperBound }.max() ?? 0
    return effectiveRangeXs.enumerated().map { (y, effectiveRangeX) in
        (0..<width)
            .map {
                return effectiveRangeX.contains($0) ? "#" : "."
            }
            .joined()
    }.joined(separator: "\n")
}

private func shipWidthThatFits(at y: Int, shipHeight: Int, code: [Int]) -> Int {
    let topRangeX = tractorEffectiveRangeX(at: y, code: code)
    let bottomRangeX = tractorEffectiveRangeX(at: y + shipHeight - 1, code: code)
    return topRangeX.clamped(to: bottomRangeX).count
}

private func tractorEffectiveRangeX(at y: Int, code: [Int]) -> Range<Int> {
    guard y >= 0 else {
        return 0..<0
    }

    let x = y
    var offset = 0
    var effectiveX = -1
    while offset <= x, effectiveX < 0 {
        if isTractorEffective(at: (x + offset, y), code: code) {
            effectiveX = x + offset
        } else if isTractorEffective(at: (x - offset, y), code: code) {
            effectiveX = x - offset
        }
        offset += 1
    }
    guard effectiveX >= 0 else {
        return 0..<0
    }

    var lowerBound: Int = effectiveX
    while lowerBound > 0, isTractorEffective(at: (lowerBound - 1, y), code: code) {
        lowerBound -= 1
    }

    var upperBound: Int = effectiveX + 1
    while isTractorEffective(at: (upperBound, y), code: code) {
        upperBound += 1
    }

    return lowerBound..<upperBound
}

private func isTractorEffective(at coordinate: (x: Int, y: Int), code: [Int]) -> Bool {
    var inputBuffer = [coordinate.x, coordinate.y]
    var outputBuffer: [Int] = []
    let processor = Processor(
        memory: code,
        input: { inputBuffer.removeFirst() },
        output: { outputBuffer.append($0) })
    while processor.canStep { processor.step() }
    return outputBuffer.last == 1
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
        case let .add(lhsMode, rhsMode, dstMode):
            let lhs = readParameterValue(at: 0, mode: lhsMode)
            let rhs = readParameterValue(at: 1, mode: rhsMode)
            let dstPointer = parameterValuePointer(at: 2, mode: dstMode)
            let sum = lhs + rhs
            writeMemory(at: dstPointer, with: sum)
        case let .multiply(lhsMode, rhsMode, dstMode):
            let lhs = readParameterValue(at: 0, mode: lhsMode)
            let rhs = readParameterValue(at: 1, mode: rhsMode)
            let dstPointer = parameterValuePointer(at: 2, mode: dstMode)
            let product = lhs * rhs
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
        case let .lessThan(lhsMode, rhsMode, dstMode):
            let lhs = readParameterValue(at: 0, mode: lhsMode)
            let rhs = readParameterValue(at: 1, mode: rhsMode)
            let dstPointer = parameterValuePointer(at: 2, mode: dstMode)
            let dstValue = lhs < rhs ? 1 : 0
            writeMemory(at: dstPointer, with: dstValue)
        case let .equal(lhsMode, rhsMode, dstMode):
            let lhs = readParameterValue(at: 0, mode: lhsMode)
            let rhs = readParameterValue(at: 1, mode: rhsMode)
            let dstPointer = parameterValuePointer(at: 2, mode: dstMode)
            let dstValue = lhs == rhs ? 1 : 0
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

        // Decode the opcode value.
        let opcode = instruction % 100
        switch opcode {
        case 1:
            let lhs = decodeParameterMode(at: 0, from: instruction)
            let rhs = decodeParameterMode(at: 1, from: instruction)
            let dst = decodeParameterMode(at: 2, from: instruction)
            return .add(lhs: lhs, rhs: rhs, dst: dst)
        case 2:
            let lhs = decodeParameterMode(at: 0, from: instruction)
            let rhs = decodeParameterMode(at: 1, from: instruction)
            let dst = decodeParameterMode(at: 2, from: instruction)
            return .multiply(lhs: lhs, rhs: rhs, dst: dst)
        case 3:
            return .input(dst: decodeParameterMode(at: 0, from: instruction))
        case 4:
            return .output(src: decodeParameterMode(at: 0, from: instruction))
        case 5:
            return .jumpIfTrue(
                src: decodeParameterMode(at: 0, from: instruction),
                dst: decodeParameterMode(at: 1, from: instruction))
        case 6:
            return .jumpIfFalse(
                src: decodeParameterMode(at: 0, from: instruction),
                dst: decodeParameterMode(at: 1, from: instruction))
        case 7:
            let lhs = decodeParameterMode(at: 0, from: instruction)
            let rhs = decodeParameterMode(at: 1, from: instruction)
            let dst = decodeParameterMode(at: 2, from: instruction)
            return .lessThan(lhs: lhs, rhs: rhs, dst: dst)
        case 8:
            let lhs = decodeParameterMode(at: 0, from: instruction)
            let rhs = decodeParameterMode(at: 1, from: instruction)
            let dst = decodeParameterMode(at: 2, from: instruction)
            return .equal(lhs: lhs, rhs: rhs, dst: dst)
        case 9:
            return .relativeBaseOffset(decodeParameterMode(at: 0, from: instruction))
        case 99:
            return .halt
        default:
            fatalError("Invalid opcode=\(opcode) in instruction=\(instruction) at position=\(position)")
        }
    }

    private func decodeParameterMode(at parameterIndex: Int, from instruction: Int) -> ParameterMode {
        let divisor: Int
        switch parameterIndex {
        case 0:
            divisor = 100
        case 1:
            divisor = 1000
        case 2:
            divisor = 10000
        case 3:
            divisor = 100000
        default:
            fatalError()
        }

        let modeValue = (instruction / divisor) % 10
        switch modeValue {
        case 0:
            return .position
        case 1:
            return .immediate
        case 2:
            return .relative
        default:
            fatalError("Invalid modeValue=\(modeValue) in instruction=\(instruction)")
        }
    }

    private func parameterValuePointer(at parameterIndex: Int, mode: ParameterMode) -> Int {
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

    private func readParameterValue(at parameterIndex: Int, mode: ParameterMode) -> Int {
        let valuePointer = parameterValuePointer(at: parameterIndex, mode: mode)
        return readMemory(at: valuePointer)
    }

    private enum Opcode {
        case add(lhs: ParameterMode, rhs: ParameterMode, dst: ParameterMode)
        case multiply(lhs: ParameterMode, rhs: ParameterMode, dst: ParameterMode)
        case input(dst: ParameterMode)
        case output(src: ParameterMode)
        case jumpIfTrue(src: ParameterMode, dst: ParameterMode)
        case jumpIfFalse(src: ParameterMode, dst: ParameterMode)
        case lessThan(lhs: ParameterMode, rhs: ParameterMode, dst: ParameterMode)
        case equal(lhs: ParameterMode, rhs: ParameterMode, dst: ParameterMode)
        case relativeBaseOffset(ParameterMode)
        case halt

        var length: Int {
            switch self {
            case .add, .multiply, .lessThan, .equal:
                return 4
            case .jumpIfTrue, .jumpIfFalse:
                return 3
            case .input, .output, .relativeBaseOffset:
                return 2
            case .halt:
                return 1
            }
        }
    }

    private enum ParameterMode {
        case position
        case immediate
        case relative
    }
}
