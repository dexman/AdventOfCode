//
//  day07.swift
//  AOC2015
//
//  Created by Arthur Dexter on 11/20/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import Foundation

func day07() throws {
    var instructions: [String: Instruction] = Dictionary(
        uniqueKeysWithValues: try readInput(day: 7).lines.map(parseInstruction(from:)))
    guard let aInstruction = instructions["a"] else {
        throw NSError(domain: "day07.a", code: 0, userInfo: nil)
    }

    var cache: [String: UInt16] = [:]
    let part1Answer = try evaluate(aInstruction, instructions: instructions, cache: &cache)
    print("Day 07, part 01: Value of a=\(part1Answer)")

    instructions["b"] = .value(part1Answer)
    cache = [:]
    let part2Answer = try evaluate(aInstruction, instructions: instructions, cache: &cache)
    print("Day 07, part 02: Value of a=\(part2Answer)")
}


fileprivate func evaluate(_ instruction: Instruction, instructions: [String: Instruction], cache: inout [String: UInt16]) throws -> UInt16 {
    switch instruction {
    case let .value(value):
        return value
    case let .wire(otherWire):
        if let cachedValue = cache[otherWire] {
            return cachedValue
        }
        guard let otherInstruction = instructions[otherWire] else {
            throw NSError(domain: "day07.\(otherWire)", code: 0, userInfo: nil)
        }
        let value = try evaluate(otherInstruction, instructions: instructions, cache: &cache)
        cache[otherWire] = value
        return value
    case let .not(otherWire):
        return ~(try evaluate(otherWire, instructions: instructions, cache: &cache))
    case let .and(lhsWire, rhsWire):
        let lhsValue = try evaluate(lhsWire, instructions: instructions, cache: &cache)
        let rhsValue = try evaluate(rhsWire, instructions: instructions, cache: &cache)
        return lhsValue & rhsValue
    case let .or(lhsWire, rhsWire):
        let lhsValue = try evaluate(lhsWire, instructions: instructions, cache: &cache)
        let rhsValue = try evaluate(rhsWire, instructions: instructions, cache: &cache)
        return lhsValue | rhsValue
    case let .lshift(otherWire, places):
        let value = try evaluate(otherWire, instructions: instructions, cache: &cache)
        return value << places
    case let .rshift(otherWire, places):
        let value = try evaluate(otherWire, instructions: instructions, cache: &cache)
        return value >> places
    }
}

fileprivate func parseInstruction<S: StringProtocol>(from string: S) throws -> (String, Instruction) {
    func parseOperand<T: StringProtocol>(_ operandString: T) -> Instruction {
        if let intValue = UInt16(operandString) {
            return .value(intValue)
        } else {
            return .wire(String(operandString))
        }
    }

    let tokens = string.split(separator: " ")
    if tokens.count == 3 {
        if let value = UInt16(tokens[0]) {
            return (String(tokens[2]), .value(value))
        } else {
            return (String(tokens[2]), .wire(String(tokens[0])))
        }
    } else if tokens.count == 4 {
        guard tokens[0] == "NOT" else {
            throw NSError(domain: "day07", code: 0, userInfo: nil)
        }
        return (String(tokens[3]), .not(parseOperand(tokens[1])))
    } else if tokens.count == 5 {
        let instruction: Instruction
        switch tokens[1] {
        case "AND":
            instruction = .and(parseOperand(tokens[0]), parseOperand(tokens[2]))
        case "OR":
            instruction = .or(parseOperand(tokens[0]), parseOperand(tokens[2]))
        case "LSHIFT":
            instruction = .lshift(parseOperand(tokens[0]), Int(tokens[2])!)
        case "RSHIFT":
            instruction = .rshift(parseOperand(tokens[0]), Int(tokens[2])!)
        default:
            throw NSError(domain: "day07", code: 0, userInfo: nil)
        }
        return (String(tokens[4]), instruction)
    } else {
        throw NSError(domain: "day07", code: 0, userInfo: nil)
    }
}


fileprivate indirect enum Instruction: CustomDebugStringConvertible {
    case value(UInt16)
    case wire(String)
    case not(Instruction)
    case and(Instruction, Instruction)
    case or(Instruction, Instruction)
    case lshift(Instruction, Int)
    case rshift(Instruction, Int)

    var debugDescription: String {
        switch self {
        case let .value(value):
            return "\(value)"
        case let .wire(wire):
            return wire
        case let .not(wire):
            return "NOT \(wire)"
        case let .and(lhs, rhs):
            return "AND \(lhs) \(rhs)"
        case let .or(lhs, rhs):
            return "OR \(lhs) \(rhs)"
        case let .lshift(wire, places):
            return "LSHIFT \(wire) \(places)"
        case let .rshift(wire, places):
            return "RSHIFT \(wire) \(places)"
        }
    }
}
