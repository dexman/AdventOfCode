//
//  day22.swift
//  AOC2015
//
//  Created by Arthur Dexter on 11/25/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import Foundation

func day22() throws {
    let initialState = State(
        player: Player(hitPoints: 50, mana: 500),
        boss: try parseBoss(from: try readInput(day: 22)),
        spells: [],
        totalCost: 0)

    guard let winningStatePart1 = findLowestCostWinningGame(initialState: initialState, hardMode: false) else {
        throw NSError(domain: "day22", code: 0, userInfo: nil)
    }
    print("Day 22, part 01, Lowest cost winning game cost \(winningStatePart1.totalCost) manna.")

    guard let winningStatePart2 = findLowestCostWinningGame(initialState: initialState, hardMode: true) else {
        throw NSError(domain: "day22", code: 0, userInfo: nil)
    }
    print("Day 22, part 02, Lowest cost winning game cost \(winningStatePart2.totalCost) manna.")
}

private func findLowestCostWinningGame(initialState: State, hardMode: Bool) -> State? {
    var lowestCostWinningGame: State?

    var games: [State] = [initialState]
    while let previousState = games.popLast() {
        for nextState in step(previousState, hardMode: hardMode) {
            guard nextState.totalCost < (lowestCostWinningGame?.totalCost ?? Int.max) else {
                // No need to consider this state if the cost is not cheaper than our cheapest cost so far.
                continue
            }

            if nextState.boss.hitPoints <= 0 {
                // Player won.
                lowestCostWinningGame = nextState
            } else if nextState.player.hitPoints > 0 {
                // Game isn't over yet.
                games.append(nextState)
            }
        }
    }

    return lowestCostWinningGame
}

private func step(_ state: State, hardMode: Bool) -> [State] {
    var state = state

    //
    // Player turn
    //

    // reduce player hp by 1 in hard mode
    if hardMode {
        let player = state.player.with(hitPoints: state.player.hitPoints - 1)
        state = state.with(player: player)
        guard player.hitPoints > 0 else {
            return [state]
        }
    }

    // activate spells
    state = applySpells(to: state)

    // Remove expired spells
    state = state.with(spells: state.spells.filter { $0.duration > 0 })

    // did boss die from spells?
    guard state.boss.hitPoints > 0 else {
        return [state]
    }

    // expand state space by choosing each possible spell
    let activeSpellNames: Set<String> = Set(state.spells.map { $0.name })
    return Spells.compactMap { spell -> State? in
        guard
            !activeSpellNames.contains(spell.name),
            spell.manaCost < state.player.mana
        else {
            return nil
        }

        // cast a spell
        var nextState = state.with(
            player: state.player.with(mana: state.player.mana - spell.manaCost),
            spells: state.spells + [spell],
            totalCost: state.totalCost + spell.manaCost)

        //
        // Boss Turn
        //

        // activate spells
        nextState = applySpells(to: nextState)

        if nextState.boss.hitPoints > 0 {
            // boss attack
            let playerArmor = nextState.spells.reduce(0) { $0 + $1.armor }
            let bossDamage = max(1, nextState.boss.damage - playerArmor)
            nextState = nextState.with(player: nextState.player.with(hitPoints: nextState.player.hitPoints - bossDamage))
        }

        // Remove expired spells
        return nextState.with(spells: nextState.spells.filter { $0.duration > 0 })
    }
}

private func applySpells(to state: State) -> State {
    var player = state.player
    var boss = state.boss
    var spells = state.spells

    var i = spells.count - 1
    while i >= 0 {
        guard boss.hitPoints > 0 else {
            break
        }
        spells[i] = spells[i].with(duration: spells[i].duration - 1)

        if spells[i].damage > 0 {
            boss = boss.with(hitPoints: boss.hitPoints - spells[i].damage)
        }

        if spells[i].healing > 0 {
            player = player.with(hitPoints: player.hitPoints + spells[i].healing)
        }

        if spells[i].manaRecharge > 0 {
            player = player.with(mana: player.mana + spells[i].manaRecharge)
        }

        i -= 1
    }

    return State(
        player: player,
        boss: boss,
        spells: spells,
        totalCost: state.totalCost)
}

private let Spells: [Spell] = [
    // Magic Missile costs 53 mana. It instantly does 4 damage.
    Spell(
        name: "Magic Missile",
        manaCost: 53,
        duration: 1,
        healing: 0,
        manaRecharge: 0,
        armor: 0,
        damage: 4),

    // Drain costs 73 mana. It instantly does 2 damage and heals you for 2 hit points.
    Spell(
        name: "Drain",
        manaCost: 73,
        duration: 1,
        healing: 2,
        manaRecharge: 0,
        armor: 0,
        damage: 2),

    // Shield costs 113 mana. It starts an effect that lasts for 6 turns. While it is active, your armor is increased by 7.
    Spell(
        name: "Shield",
        manaCost: 113,
        duration: 6,
        healing: 0,
        manaRecharge: 0,
        armor: 7,
        damage: 0),

    // Poison costs 173 mana. It starts an effect that lasts for 6 turns. At the start of each turn while it is active, it deals the boss 3 damage.
    Spell(
        name: "Poison",
        manaCost: 173,
        duration: 6,
        healing: 0,
        manaRecharge: 0,
        armor: 0,
        damage: 3),

    // Recharge costs 229 mana. It starts an effect that lasts for 5 turns. At the start of each turn while it is active, it gives you 101 new mana.
    Spell(
        name: "Recharge",
        manaCost: 229,
        duration: 5,
        healing: 0,
        manaRecharge: 101,
        armor: 0,
        damage: 0),
]

private struct State: Equatable {
    let player: Player
    let boss: Boss
    let spells: [Spell]
    let totalCost: Int

    func with(player: Player? = nil, boss: Boss? = nil, spells: [Spell]? = nil, totalCost: Int? = nil) -> State {
        return State(
            player: player ?? self.player,
            boss: boss ?? self.boss,
            spells: spells ?? self.spells,
            totalCost: totalCost ?? self.totalCost)
    }
}

private struct Spell: Hashable {
    let name: String
    let manaCost: Int
    let duration: SpellDuration

    let healing: Int
    let manaRecharge: Int
    let armor: Int

    let damage: Int

    func with(duration: Int) -> Spell {
        return Spell(
            name: self.name,
            manaCost: self.manaCost,
            duration: duration,
            healing: self.healing,
            manaRecharge: self.manaRecharge,
            armor: self.armor,
            damage: self.damage)
    }
}

private typealias SpellDuration = Int

private struct Player: Equatable {
    let hitPoints: Int
    let mana: Int

    func with(hitPoints: Int? = nil, mana: Int? = nil) -> Player {
        return Player(
            hitPoints: hitPoints ?? self.hitPoints,
            mana: mana ?? self.mana)
    }
}

private struct Boss: Equatable {
    let hitPoints: Int
    let damage: Int

    func with(hitPoints: Int? = nil) -> Boss {
        return Boss(
            hitPoints: hitPoints ?? self.hitPoints,
            damage: self.damage)
    }
}

private func parseBoss<S: StringProtocol>(from string: S) throws -> Boss {
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
        throw ParseError<Boss>(string)
    }
    guard let damage = statsDictionary["Damage"] else {
        throw ParseError<Boss>(string)
    }
    return Boss(
        hitPoints: hitPoints,
        damage: damage)
}
