//
//  day11.swift
//  AOC2019
//
//  Created by Arthur Dexter on 12/13/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import AdventOfCodeUtils
import CoreGraphics
import Foundation

func day11() throws {
    let (_, part1PaintedPositions) = try paintPanels(initialPanelColor: .black)
    print("Day 11, part 01: Total panels painted=\(part1PaintedPositions.count)")

    let (part2Panels, _) = try paintPanels(initialPanelColor: .white)
    let filename = "\(#file).png"
    print("Day 11, part 02: Message at=\(filename)")

    let context = try CGContext(
        data: nil,
        width: part2Panels[0].count,
        height: part2Panels.count,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: CGColorSpaceCreateDeviceGray(),
        bitmapInfo: CGImageAlphaInfo.none.rawValue).required()
    for (y, row) in part2Panels.reversed().enumerated() {
        for (x, panel) in row.enumerated() {
            switch panel {
            case .black:
                context.setFillColor(gray: 1.0, alpha: 1.0)
            case .white:
                context.setFillColor(gray: 0.0, alpha: 1.0)
            }
            context.fill(CGRect(x: x, y: y, width: 1, height: 1))
        }
    }
    let image = try context.makeImage().required()
    let destination = try CGImageDestinationCreateWithURL(
        URL(fileURLWithPath: filename) as CFURL,
        kUTTypePNG,
        1, nil).required()
    CGImageDestinationAddImage(destination, image, nil)
    CGImageDestinationFinalize(destination)
}

private func paintPanels(initialPanelColor: PanelColor) throws -> (panels: [[PanelColor]], painted: Set<Position>) {
    let code = try Processor.parseIntcode(from: readInput())

    let size: (width: Int, height: Int) = (80, 57)
    var panels: [[PanelColor]] = Array(
        repeating: Array(
            repeating: .black,
            count: size.width),
        count: size.height)
    var paintedPositions: Set<Position> = []
    var robotPosition = Position(x: 35, y: 27)
    var robotDirection: Direction = .up

    panels[robotPosition.y][robotPosition.x] = initialPanelColor

    var outputs: [Int] = []
    let processor = Processor(
        memory: code,
        input: {
            panels[robotPosition.y][robotPosition.x].rawValue
        },
        output: {
            outputs.append($0)
        })

    while processor.canStep {
        processor.step()

        if outputs.count == 2 {
            let color = try PanelColor(rawValue: outputs[0]).required()
            panels[robotPosition.y][robotPosition.x] = color
            paintedPositions.insert(robotPosition)

            let turn = try Turn(rawValue: outputs[1]).required()
            robotDirection = robotDirection.turned(by: turn)
            robotPosition = robotPosition.moved(in: robotDirection)

            outputs.removeAll(keepingCapacity: true)
        }
    }

    return (panels, paintedPositions)
}

private enum Direction {
    case up
    case down
    case left
    case right

    func turned(by turn: Turn) -> Direction {
        switch (self, turn) {
        case (.up, .left):
            return .left
        case (.up, .right):
            return .right
        case (.down, .left):
            return .right
        case (.down, .right):
            return .left
        case (.left, .left):
            return .down
        case (.left, .right):
            return .up
        case (.right, .left):
            return .up
        case (.right, .right):
            return .down
        }
    }
}

private enum Turn: Int {
    case left
    case right
}

private enum PanelColor: Int {
    case black
    case white
}

private struct Position: Hashable {
    let x: Int
    let y: Int

    func moved(in direction: Direction) -> Position {
        switch direction {
        case .up:
            return Position(x: x, y: y - 1)
        case .down:
            return Position(x: x, y: y + 1)
        case .left:
            return Position(x: x - 1, y: y)
        case .right:
            return Position(x: x + 1, y: y)
        }
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
