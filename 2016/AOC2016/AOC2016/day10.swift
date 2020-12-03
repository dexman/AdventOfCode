//
//  day10.swift
//  AOC2016
//
//  Created by Arthur Dexter on 11/26/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import AdventOfCodeUtils
import Foundation

func day10() throws {
    var instructions = try readInput()
        .lines
        .map(parseInstruction(from:))

    var bots: [Int: [Int]] = [:]
    var outputs: [Int: [Int]] = [:]
    while !instructions.isEmpty {
        instructions = instructions.filter { arg in
            let (botIndex, instruction) = arg
            switch instruction {
            case let .give(lowRecipient, highRecipient):
                guard
                    let bot = bots[botIndex],
                    bot.count == 2,
                    let lowValue = bot.min(),
                    let highValue = bot.max()
                else {
                    return true
                }

                for (value, recipient) in zip([lowValue, highValue], [lowRecipient, highRecipient]) {
                    switch recipient {
                    case let .bot(botIndex):
                        bots[botIndex, default: []].append(value)
                    case let .output(outputIndex):
                        outputs[outputIndex, default: []].append(value)
                    }
                }
                return false
            case let .value(value):
                bots[botIndex, default: []].append(value)
                return false
            }
        }
    }

    let part1Bot = try bots.first(where: { Set($0.value) == Set([17, 61]) }).required()
    print("Day 10, part 01: Bot with values 17 and 61=\(part1Bot.key)")

    let part2Result = [0, 1, 2].compactMap { outputs[$0] }.flatMap { $0 }.reduce(1, *)
    print("Day 10, part 02: Product of outputs 0,1,2=\(part2Result)")
}

private func parseInstruction<S: StringProtocol>(from string: S) throws -> (bot: Int, instruction: Instruction) {
    let tokens = string.split(separator: " ")
    if tokens.count == 12 {
        // bot 153 gives low to bot 105 and high to bot 10
        let bot = try Int.parse(tokens[1])
        let lowRecipient = try parseRecipient(from: tokens[5...6])
        let highRecipient = try parseRecipient(from: tokens[10...11])
        return (bot, .give(low: lowRecipient, high: highRecipient))
    } else if tokens.count == 6 {
        // value 11 goes to bot 124
        let bot = try Int.parse(tokens[5])
        let value = try Int.parse(tokens[1])
        return (bot, .value(value))
    } else {
        throw NSError(domain: "day10", code: 0, userInfo: nil)
    }
}

private func parseRecipient<S: RandomAccessCollection>(from collection: S) throws -> Recipient where S.Element: StringProtocol {
    let index = try Int.parse(collection.last ?? "")
    switch collection.first {
    case "output":
        return .output(index)
    case "bot":
        return .bot(index)
    default:
        throw NSError(domain: "day10", code: 0, userInfo: nil)
    }
}

private enum Instruction {
    case give(low: Recipient, high: Recipient)
    case value(Int)
}

private enum Recipient {
    case bot(Int)
    case output(Int)
}
