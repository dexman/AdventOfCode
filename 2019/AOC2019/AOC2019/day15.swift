//
//  day15.swift
//  AOC2019
//
//  Created by Arthur Dexter on 12/20/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import AdventOfCodeUtils
import Foundation

func day15() throws {
    let code = try Processor.parseIntcode(from: readInput())

    let tiles = explore(code: code)
    let startPosition = Position(x: 0, y: 0)
    let goalPosition = try (tiles.first { position, tile in
        tile == .goal
    }?.key).required()

//    print(format(tiles, robot: startPosition))

    let possiblePath = shortestPath(in: tiles, from: startPosition, to: goalPosition)
    let path = try (possiblePath?.dropFirst()).required()
    print("Day 15, part 01: Shortest path to goal is \(path.count) steps.")

    let timeToOxygenate = oxygenate(tiles: tiles, start: goalPosition)
    print("Day 15, part 01: Time to fully oxygenate is \(timeToOxygenate) seconds.")
}

private func shortestPath(in tiles: [Position: Tile], from start: Position, to goal: Position) -> [Position]? {
    return aStar(
        start: start,
        goal: goal,
        distance: { _, _ in 1 },
        heuristicDistance: { _ in 0 },
        neighbors: {
            Set($0.neighbors.filter { tiles[$0] != nil && tiles[$0] != .wall })
    })
}

private func oxygenate(tiles: [Position: Tile], start: Position) -> Int {
    let oxygenatable: Set<Position> = Set(tiles.compactMapValues { $0 == .passage || $0 == .goal ? $0 : nil }.keys)
    var oxygenated: Set<Position> = [start]
    var seconds = 0
    while oxygenated.count < oxygenatable.count {
        for position in oxygenated {
            oxygenated.formUnion(position.neighbors.filter { oxygenatable.contains($0) })
        }
        seconds += 1
    }
    return seconds
}

private func explore(code: [Int]) -> [Position: Tile] {
    var inputBuffer: [Int] = []
    var outputBuffer: [Int] = []
    let processor = Processor(
        memory: code,
        input: { inputBuffer.removeFirst() },
        output: { outputBuffer.append($0) })

    func moveRobot(direction: Int) -> Tile {
        guard inputBuffer.isEmpty else { fatalError("Input buffer not empty") }
        inputBuffer.append(direction)
        while processor.canStep, outputBuffer.isEmpty { processor.step() }
        switch outputBuffer.popLast() {
        case 0:
            return .wall
        case 1:
            return .passage
        case 2:
            return .goal
        default:
            fatalError("Did not understand output.")
        }
    }

    let initialPosition = Position(x: 0, y: 0)
    var tiles: [Position: Tile] = [initialPosition: .passage]
    var stack: [Position] = [initialPosition]
    while let currentPosition = stack.popLast() {
        let neighbors = currentPosition.neighbors.filter({ tiles[$0] == nil }).reversed()

        let nextPosition = neighbors.first { neighbor in
            let neighborTile = moveRobot(direction: currentPosition.movementCommand(to: neighbor))
            guard tiles[neighbor] == nil || tiles[neighbor] == neighborTile else {
                fatalError("Tile corruption")
            }
            tiles[neighbor] = neighborTile
            return neighborTile != .wall
        }

        if let nextPosition = nextPosition {
            stack.append(currentPosition)
            stack.append(nextPosition)
        } else if let previousPosition = stack.last {
            let previousTile = moveRobot(direction: currentPosition.movementCommand(to: previousPosition))
            guard tiles[previousPosition] == previousTile else {
                fatalError("Tile corruption for previous")
            }
        }
    }

    return tiles
}

private func format(_ tiles: [Position: Tile], robot: Position) -> String {
    let xPositions = tiles.keys.map { $0.x }
    let xMin = xPositions.min() ?? 0
    let xMax = xPositions.max() ?? 0

    let yPositions = tiles.keys.map { $0.y }
    let yMin = yPositions.min() ?? 0
    let yMax = yPositions.max() ?? 0

    return (yMin...yMax).map { y in
        (xMin...xMax).map { x in
            let position = Position(x: x, y: y)

            if position == robot {
                return "D"
            }

            switch tiles[position] {
            case .none:
                return " "
            case .wall:
                return "#"
            case .passage:
                return "."
            case .goal:
                return "G"
            }
        }.joined()
    }.joined(separator: "\n")
}

private enum Tile {
    case wall
    case passage
    case goal
}

private struct Position: Hashable, CustomDebugStringConvertible {
    let x: Int
    let y: Int

    var debugDescription: String {
        return "(\(x),\(y))"
    }

    var neighbors: [Position] {
        return [
            Position(x: x, y: y - 1),
            Position(x: x, y: y + 1),
            Position(x: x - 1, y: y),
            Position(x: x + 1, y: y),
        ]
    }

    func manhattanDistance(to other: Position) -> Int {
        return abs(x - other.x) + abs(y - other.y)
    }

    func movementCommand(to other: Position) -> Int {
        if other.y < y {
            return 1
        } else if other.y > y {
            return 2
        } else if other.x < x {
            return 3
        } else {
            return 4
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
