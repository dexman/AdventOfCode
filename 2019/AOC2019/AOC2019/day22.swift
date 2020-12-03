//
//  day22.swift
//  AOC2019
//
//  Created by Arthur Dexter on 12/22/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import AdventOfCodeUtils
import Foundation

func day22() throws {
    let techniques = try parseTechniques(from: readInput())

    let part1FinalDeck = techniques.reduce(Deck.factoryDeck(count: 10007)) { deck, technique in
        switch technique {
        case .dealIntoNewStack:
            return deck.dealIntoNewStack()
        case let .cut(n):
            return deck.cut(n)
        case let .dealWithIncrement(n):
            return deck.dealWithIncrement(n)
        }
    }
    let positionOf2019 = try (0..<part1FinalDeck.count).first(where: { part1FinalDeck[$0] == 2019 }).required()
    print("Day 22, part 01: Position of card 2019: \(positionOf2019)")

    var deck = Deck.factoryDeck(count: 119_315_717_514_047)
    let start = (0...2020).map { deck[$0] }
    var iterations = 0
    while true {
        let shuffledDeck = techniques.reduce(deck) { deck, technique in
            switch technique {
            case .dealIntoNewStack:
                return deck.dealIntoNewStack()
            case let .cut(n):
                return deck.cut(n)
            case let .dealWithIncrement(n):
                return deck.dealWithIncrement(n)
            }
        }
        let shuffledStart = (0...2020).map { shuffledDeck[$0] }

        if start == shuffledStart {
            break
        }

        iterations += 1
    }
    print("repeated after \(iterations) iterations")
//    let part2DeckCount = 119_315_717_514_047
//    let part2IterationCount = 101_741_582_076_661
//    var part2FinalDeck = factoryDeck(part2DeckCount) // This won't work!!!
//    for _ in 0..<part2IterationCount {
//        part2FinalDeck = techniques.reduce(part2FinalDeck, { cards, technique in
//            switch technique {
//            case .dealIntoNewStack:
//                return dealIntoNewStack(cards)
//            case let .cut(n):
//                return cutCards(n, cards)
//            case let .dealWithIncrement(n):
//                return dealWithIncrement(n, cards)
//            }
//        })
//    }
//
//    let valueOfCard2020 = part2FinalDeck[2020]
//    print("Day 22, part 02: Value of card 2020: \(valueOfCard2020)")
}

private struct Deck {

    static func factoryDeck(count: Int) -> Deck {
        return Deck(count: count, elementAtIndex: { $0 })
    }

    init(count: Int, elementAtIndex: @escaping (Int) -> Int) {
        self.count = count
        self.elementAtIndex = elementAtIndex
    }

    let count: Int

    subscript(index: Int) -> Int {
        guard index >= 0 else { fatalError("Index < 0") }
        guard index < count else { fatalError("Index > count") }
        return elementAtIndex(index)
    }

    func dealIntoNewStack() -> Deck {
        return Deck(count: count) { [count, elementAtIndex] index in
            elementAtIndex(count - index - 1)
        }
    }

    func cut(_ n: Int) -> Deck {
        let cutLength = n >= 0 ? n : count + n
        return Deck(count: count) { [count, elementAtIndex] index in
            if index < count - cutLength {
                return elementAtIndex(index + cutLength)
            } else {
                return elementAtIndex(index - count + cutLength)
            }
        }
    }

    func dealWithIncrement(_ n: Int) -> Deck {
        return Deck(count: count) { [count, elementAtIndex] index in
            return elementAtIndex(n.modInv(count) * index % count)
        }
    }

    private let elementAtIndex: (Int) -> Int
}

private func parseTechniques(from string: String) throws -> [Technique] {
    return try string.lines.map { line in
        if line == "deal into new stack" {
            return .dealIntoNewStack
        } else if line.starts(with: "deal with increment ") {
            let n = try Int.parse(line.replacingOccurrences(of: "deal with increment ", with: ""))
            return .dealWithIncrement(n)
        } else if line.starts(with: "cut ") {
            let n = try Int.parse(line.replacingOccurrences(of: "cut ", with: ""))
            return .cut(n)
        } else {
            throw ParseError<Technique>(string)
        }
    }
}

private enum Technique {
    case dealIntoNewStack
    case cut(Int)
    case dealWithIncrement(Int)
}

// https://rosettacode.org/wiki/Modular_inverse#Swift
extension BinaryInteger {
  @inlinable
  public func modInv(_ mod: Self) -> Self {
    var (m, n) = (mod, self)
    var (x, y) = (Self(0), Self(1))

    while n != 0 {
      (x, y) = (y, x - (m / n) * y)
      (m, n) = (n, m % n)
    }

    while x < 0 {
      x += mod
    }

    return x
  }
}
