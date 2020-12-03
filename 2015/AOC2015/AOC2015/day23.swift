//
//  day23.swift
//  AOC2015
//
//  Created by Arthur Dexter on 11/25/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import Foundation

func day23() throws {
    let instructions = try readInput(day: 23).lines.map(parseInstruction(from:))

    let processor = Processor()
    processor.program = instructions
    while processor.step() {}
    print("Day 23, part 01: Value of register b=\(processor.registers[.b, default: 0])")

    let processorPart2 = Processor()
    processorPart2.registers[.a] = 1
    processorPart2.program = instructions
    while processorPart2.step() {}
    print("Day 23, part 02: Value of register b=\(processorPart2.registers[.b, default: 0])")

}

private class Processor: CustomDebugStringConvertible {
    var registers: [Register: UInt] = [
        .a: 0,
        .b: 0
    ]

    var programCounter: Int = 0

    var program: [Instruction] = []

    func step() -> Bool {
        guard self.programCounter >= 0, self.programCounter < self.program.count else {
            return false
        }

        switch self.program[self.programCounter] {
        case let .hlf(register):
            self.registers[register, default: 0] /= 2
        case let .tpl(register):
            self.registers[register, default: 0] *= 3
        case let .inc(register):
            self.registers[register, default: 0] += 1
        case let .jmp(offset):
            self.programCounter += (offset - 1)
        case let .jie(register, offset):
            if self.registers[register, default: 0] % 2 == 0 {
                self.programCounter += (offset - 1)
            }
        case let .jio(register, offset):
            if self.registers[register, default: 0] == 1 {
                self.programCounter += (offset - 1)
            }
        }

        self.programCounter += 1

        return self.programCounter >= 0 && self.programCounter < self.program.count
    }

    var debugDescription: String {
        return "a=\(self.registers[.a, default: 0]) b=\(self.registers[.b, default: 0]) pc=\(self.programCounter)"
    }
}

private func parseInstruction<S: StringProtocol>(from string: S) throws -> Instruction {
    let tokens = string
        .replacingOccurrences(of: ",", with: "")
        .split(separator: " ")

    guard !tokens.isEmpty else {
        throw ParseError<Instruction>(string)
    }

    switch tokens[0] {
    case "hlf":
        return .hlf(try parseRegister(from: tokens[1]))
    case "tpl":
        return .tpl(try parseRegister(from: tokens[1]))
    case "inc":
        return .inc(try parseRegister(from: tokens[1]))
    case "jmp":
        return .jmp(try Int(tokens[1]))
    case "jie":
        return .jie(try parseRegister(from: tokens[1]), try Int(tokens[2]))
    case "jio":
        return .jio(try parseRegister(from: tokens[1]), try Int(tokens[2]))
    default:
        throw ParseError<Instruction>(tokens[0])
    }
}

private func parseRegister<S: StringProtocol>(from string: S) throws -> Register {
    if string == "a" {
        return .a
    } else if string == "b" {
        return .b
    } else {
        throw ParseError<Register>(string)
    }
}


private enum Instruction: CustomDebugStringConvertible {
    case hlf(Register)
    case tpl(Register)
    case inc(Register)
    case jmp(Int)
    case jie(Register, Int)
    case jio(Register, Int)

    var debugDescription: String {
        switch self {
        case let .hlf(register):
            return "hlf \(register)"
        case let .tpl(register):
            return "tpl \(register)"
        case let .inc(register):
            return "inc \(register)"
        case let .jmp(offset):
            return "jmp \(offset)"
        case let .jie(register, offset):
            return "jie \(register) \(offset)"
        case let .jio(register, offset):
            return "jio \(register) \(offset)"
        }
    }
}

private enum Register {
    case a
    case b
}
