//
//  day12.swift
//  AOC2016
//
//  Created by Arthur Dexter on 11/28/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import AdventOfCodeUtils
import Foundation

func day12() throws {
    let program = try readInput().lines.map(parseOpcode(from:))
    var processor = Processor(program: program)
    while processor.canStep {
        processor.step()
    }
    print("Day 12, part 01: Value of register a=\(processor.registers[Processor.Register.a.rawValue])")

    processor = Processor(program: program)
    processor.registers[Processor.Register.c.rawValue] = 1
    while processor.canStep {
        processor.step()
    }
    print("Day 12, part 02: Value of register a=\(processor.registers[Processor.Register.a.rawValue])")
}

private func parseOpcode<S: StringProtocol>(from string: S) throws -> Processor.Opcode {
    let tokens = string.split(separator: " ")
    switch tokens.first {
    case "cpy":
        guard tokens.count == 3 else { throw NSError(domain: "day12", code: 0, userInfo: nil) }
        return try .cpy(parseOperand(from: tokens[1]), parseRegister(from: tokens[2]))
    case "inc":
        guard tokens.count == 2 else { throw NSError(domain: "day12", code: 0, userInfo: nil) }
        return try .inc(parseRegister(from: tokens[1]))
    case "dec":
        guard tokens.count == 2 else { throw NSError(domain: "day12", code: 0, userInfo: nil) }
        return try .dec(parseRegister(from: tokens[1]))
    case "jnz":
        guard tokens.count == 3 else { throw NSError(domain: "day12", code: 0, userInfo: nil) }
        return try .jnz(parseOperand(from: tokens[1]), Int(tokens[2])!)
    default:
        throw NSError(domain: "day12", code: 0, userInfo: nil)
    }
}

private func parseOperand<S: StringProtocol>(from string: S) throws -> Processor.Operand {
    if let intValue = Int(String(string)) {
        return .value(intValue)
    } else {
        return .register(try parseRegister(from: string))
    }
}

private func parseRegister<S: StringProtocol>(from string: S) throws -> Processor.Register {
    switch string {
    case "a":
        return .a
    case "b":
        return .b
    case "c":
        return .c
    case "d":
        return .d
    default:
        throw NSError(domain: "day12", code: 0, userInfo: nil)
    }
}

private class Processor {
    enum Register: Int {
        case a
        case b
        case c
        case d
    }

    enum Operand {
        case register(Register)
        case value(Int)
    }

    enum Opcode {
        case cpy(Operand, Register)
        case inc(Register)
        case dec(Register)
        case jnz(Operand, Int)
    }

    var registers: [Int] = Array(repeating: 0, count: Register.d.rawValue + 1)

    var programCounter: Int = 0

    let program: [Opcode]

    var canStep: Bool {
        return self.programCounter >= 0 && self.programCounter < self.program.count
    }

    init(program: [Opcode]) {
        self.program = program
    }

    func step() {
        assert(self.canStep)
        switch self.program[self.programCounter] {
        case let .cpy(src, dst):
            let srcValue: Int
            switch src {
            case let .register(register):
                srcValue = self.registers[register.rawValue]
            case let .value(value):
                srcValue = value
            }
            self.registers[dst.rawValue] = srcValue
        case let .inc(register):
            self.registers[register.rawValue] += 1
        case let .dec(register):
            self.registers[register.rawValue] -= 1
        case let .jnz(operand, offset):
            let operandValue: Int
            switch operand {
            case let .register(register):
                operandValue = self.registers[register.rawValue]
            case let .value(value):
                operandValue = value
            }
            if operandValue != 0 {
                self.programCounter += offset - 1
            }
        }
        self.programCounter += 1
    }
}
