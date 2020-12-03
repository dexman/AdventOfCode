//
//  day21.swift
//  AOC2015
//
//  Created by Arthur Dexter on 11/23/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import Foundation

func day21() throws {
    let bossStats = try parseCharacterStats(from: try readInput(day: 21))

    let weaponCombinations = Weapons.combinations.filter { $0.count == 1 }
    let armorCombinations = Armor.combinations.filter { $0.count <= 1 }
    let ringCombinations = Rings.combinations.filter { $0.count <= 2 }

    var winningCosts: [Int] = []
    var losingCosts: [Int] = []
    for weapon in weaponCombinations {
        for armor in armorCombinations {
            for rings in ringCombinations {
                let playerItems = (weapon + armor + rings)
                let playerDamage = playerItems.reduce(0) { damage, itemStats in damage + itemStats.damage }
                let playerArmor = playerItems.reduce(0) { armor, itemStats in armor + itemStats.armor }
                let playerCost = playerItems.reduce(0) { cost, itemStats in cost + itemStats.cost }
                let playerStats = CharacterStats(hitPoints: 100, damage: playerDamage, armor: playerArmor)
                if playerWouldWin(player: playerStats, boss: bossStats) {
                    winningCosts.append(playerCost)
                } else {
                    losingCosts.append(playerCost)
                }
            }
        }
    }

    let lowestWinningCost = winningCosts.min() ?? -1
    print("Day 21, part 01: Least gold to win=\(lowestWinningCost)")

    let highestLosingCost = losingCosts.max() ?? -1
    print("Day 21, part 02: Most gold to lose=\(highestLosingCost)")
}

private func playerWouldWin(player: CharacterStats, boss: CharacterStats) -> Bool {
    let playerDamagePerTurn = max(1, player.damage - boss.armor)
    let bossLifetime = Int(ceil((Double(boss.hitPoints) / Double(playerDamagePerTurn))))

    let bossDamagePerTurn = max(1, boss.damage - player.armor)
    let playerLifetime = Int(ceil((Double(player.hitPoints) / Double(bossDamagePerTurn))))

    return bossLifetime <= playerLifetime
}

private let Weapons: [ItemStats] = [
    ItemStats(name: "Dagger", cost: 8, damage: 4, armor: 0),
    ItemStats(name: "Shortsword", cost: 10, damage: 5, armor: 0),
    ItemStats(name: "Warhammer", cost: 25, damage: 6, armor: 0),
    ItemStats(name: "Longsword", cost: 40, damage: 7, armor: 0),
    ItemStats(name: "Greataxe", cost: 74, damage: 8, armor: 0),
]

private let Armor: [ItemStats] = [
    ItemStats(name: "Leather", cost: 13, damage: 0, armor: 1),
    ItemStats(name: "Chainmail", cost: 31, damage: 0, armor: 2),
    ItemStats(name: "Splintmail", cost: 53, damage: 0, armor: 3),
    ItemStats(name: "Bandedmail", cost: 75, damage: 0, armor: 4),
    ItemStats(name: "Platemail", cost: 102, damage: 0, armor: 5),
]

private let Rings: [ItemStats] = [
    ItemStats(name: "Damage +1", cost: 25, damage: 1, armor: 0),
    ItemStats(name: "Damage +2", cost: 50, damage: 2, armor: 0),
    ItemStats(name: "Damage +3", cost: 100, damage: 3, armor: 0),
    ItemStats(name: "Defense +1", cost: 20, damage: 0, armor: 1),
    ItemStats(name: "Defense +2", cost: 40, damage: 0, armor: 2),
    ItemStats(name: "Defense +3", cost: 80, damage: 0, armor: 3),
]

private func parseCharacterStats<S: StringProtocol>(from string: S) throws -> CharacterStats {
    let keyValuePairs = try string
        .lines
        .map { line in
            line.split(separator: ": ")
        }
        .map { keyValueArray -> (String, Int) in
            let key = String(keyValueArray[0])
            let value: Int = try Int(keyValueArray[1])
            return (key, value)
        }
    let statsDictionary: [String: Int] = Dictionary(uniqueKeysWithValues: keyValuePairs)
    guard let hitPoints = statsDictionary["Hit Points"] else {
        throw ParseError<CharacterStats>(string)
    }
    guard let damage = statsDictionary["Damage"] else {
        throw ParseError<CharacterStats>(string)
    }
    guard let armor = statsDictionary["Armor"] else {
        throw ParseError<CharacterStats>(string)
    }
    return CharacterStats(
        hitPoints: hitPoints,
        damage: damage,
        armor: armor)
}

private struct ItemStats {
    let name: String
    let cost: Int
    let damage: Int
    let armor: Int
}

private struct CharacterStats {
    let hitPoints: Int
    let damage: Int
    let armor: Int
}
