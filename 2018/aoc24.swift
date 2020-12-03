import Foundation

extension String {
    func match(pattern: String) -> [String.SubSequence]? {
        let matchRange = NSRange(startIndex..<endIndex, in: self)
        return try! NSRegularExpression(pattern: pattern)
            .firstMatch(in: self, range: matchRange)
            .map { result in
                return (0..<result.numberOfRanges).compactMap { rangeIndex in
                    Range(result.range(at: rangeIndex), in: self).map { range in
                        self[range]
                    }
                }
        }
    }
}

class Army: CustomStringConvertible {
    let name: String
    let groups: [Group]

    var isAlive: Bool {
        return groups.contains {
            $0.count > 0
        }
    }

    var description: String {
        return "Army<name=\(name) groups=\(groups)>"
    }

    init(name: String, groups: [Group]) {
        self.name = name
        self.groups = groups
    }
}

class Group: CustomStringConvertible, Hashable {
    let armyName: String
    let id: String
    private(set) var count: Int
    let hitPointsEach: Int
    let initiative: Int
    let attackDamage: Int
    let attackType: String
    let immunities: Set<String>
    let weaknesses: Set<String>

    var effectivePower: Int {
        return count * attackDamage
    }

    func damage(to target: Group) -> Int {
        if armyName == target.armyName || count < 1 || target.count < 1 {
            return 0
        } else if target.immunities.contains(attackType) {
            return 0
        } else if target.weaknesses.contains(attackType) {
            return 2 * effectivePower
        } else {
            return effectivePower
        }
    }

    func attack(_ target: Group) {
        let d = damage(to: target)
        let c = min(d / target.hitPointsEach, target.count)
        // print("\(armyName) group \(id) attacks defending group \(target.id), killing \(c) units.")
        target.count -= c
    }

    var description: String {
        return "(\(armyName)/\(id) count=\(count) hp=\(hitPointsEach))"
    }

    static func == (_ lhs: Group, _ rhs: Group) -> Bool {
        return lhs === rhs
    }

    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }

    init(armyName: String, id: String, count: Int, hitPointsEach: Int, initiative: Int, attackDamage: Int, attackType: String, immunities: Set<String>, weaknesses: Set<String>) {
        self.armyName = armyName
        self.id = id
        self.count = count
        self.hitPointsEach = hitPointsEach
        self.initiative = initiative
        self.attackDamage = attackDamage
        self.attackType = attackType
        self.immunities = immunities
        self.weaknesses = weaknesses
    }
}

func parseArmies(from input: String, immuneBoost: Int) -> [Army] {
    func parseGroup(from input: String, armyName: String, id: String) -> Group? {
        guard
            let count = input
                .match(pattern: "^(\\d+) units")?
                .compactMap({ Int($0) })
                .first,
            let hitPointsEach = input
                .match(pattern: "(\\d+) hit points")?
                .compactMap({ Int($0) })
                .first,
            let attackDamage = input
                .match(pattern: "attack that does (\\d+)")?
                .compactMap({ Int($0) })
                .first,
            let attackType = input
                .match(pattern: "does \\d+ (\\w+) damage")?
                .map({ String($0) })
                .last,
            let initiative = input
                .match(pattern: "initiative (\\d+)$")?
                .compactMap({ Int($0) })
                .first
            else {
                return nil
        }

        let immunities = input
            .match(pattern: "immune to (.+?)[;)]")?
            .suffix(from: 1)
            .map({ $0.replacingOccurrences(of: " ", with: "") })
            .flatMap({ $0.split(separator: ",") })
            .map({ String($0) })
        let weaknesses = input
            .match(pattern: "weak to (.+?)[;)]")?
            .suffix(from: 1)
            .map({ $0.replacingOccurrences(of: " ", with: "") })
            .flatMap({ $0.split(separator: ",") })
            .map({ String($0) })

        let boostedAttackDamage: Int
        if armyName == "Immune System" {
            boostedAttackDamage = attackDamage + immuneBoost
        } else {
            boostedAttackDamage = attackDamage
        }

        return Group(
            armyName: armyName,
            id: id,
            count: count,
            hitPointsEach: hitPointsEach,
            initiative: initiative,
            attackDamage: boostedAttackDamage,
            attackType: attackType,
            immunities: Set(immunities ?? []),
            weaknesses: Set(weaknesses ?? []))
    }

    var groups = [Army]()

    var currentArmyName = ""
    var currentArmyGroups = [Group]()

    var lineIndex = 1
    for line in input.split(separator: "\n").map({ String($0) }) {
        if line.hasSuffix(":") {
            if !currentArmyName.isEmpty {
                groups.append(Army(name: currentArmyName, groups: currentArmyGroups))
            }
            currentArmyName = line.replacingOccurrences(of: ":", with: "")
            currentArmyGroups = [Group]()
        } else if let group = parseGroup(from: line, armyName: currentArmyName, id: "\(currentArmyGroups.count + 1)") {
            currentArmyGroups.append(group)
        } else {
            print("Failed to parse group at line \(lineIndex)")
            exit(1)
        }
        lineIndex += 1
    }
    if !currentArmyName.isEmpty {
        groups.append(Army(name: currentArmyName, groups: currentArmyGroups))
    }
    return groups
}

func format(_ armies: [Army]) -> String {
    return armies.map { army in
        var result = army.name + "\n"
        if army.groups.isEmpty {
            result += "No groups remain."
        } else {
            result += army.groups.filter { $0.count > 0 }.map { group in
                "Group \(group.id) contains \(group.count) units."
                }.joined(separator: "\n")
        }
        return result
        }.joined(separator: "\n")
}

func selectTargets(from armies: [Army]) -> [(attacker: Group, target: Group)] {
    var possibleTargets = Set<Group>(armies.flatMap { $0.groups })
    return armies.flatMap { army -> [(attacker: Group, target: Group)] in
        return army
            .groups
            .sorted { lhs, rhs in
                if rhs.effectivePower < lhs.effectivePower {
                    return true
                } else if rhs.effectivePower == lhs.effectivePower {
                    return rhs.initiative < lhs.initiative
                } else {
                    return false
                }
            }
            .compactMap { attacker -> (attacker: Group, target: Group)? in
                return possibleTargets
                    .lazy
                    .map { ($0, attacker.damage(to: $0)) }
                    .max { lhsAttackerDamagePair, rhsAttackerDamagePair in
                        let (lhs, rhs) = (lhsAttackerDamagePair.0, rhsAttackerDamagePair.0)
                        let lhsDamage = lhsAttackerDamagePair.1
                        let rhsDamage = rhsAttackerDamagePair.1
                        if lhsDamage != rhsDamage {
                            return lhsDamage < rhsDamage
                        } else if lhs.effectivePower != rhs.effectivePower {
                            return lhs.effectivePower < rhs.effectivePower
                        } else {
                            return lhs.initiative < rhs.initiative
                        }
                    }
                    .flatMap {
                        let target = $0.0
                        if attacker.damage(to: target) > 0 {
                            possibleTargets.remove(target)
                            return (attacker: attacker, target: target)
                        } else {
                            return nil
                        }
                    }
        }
    }
}

func attackTargets(_ targets: [(attacker: Group, target: Group)]) {
    let sortedTargets = targets.sorted { lhs, rhs in
        rhs.attacker.initiative < lhs.attacker.initiative
    }
    for (attacker, target) in sortedTargets {
        attacker.attack(target)
    }
}

func fight(_ armies: [Army]) -> Bool {
    if armies.filter({ $0.isAlive }).count < 2 {
        return false
    }
    let targets = selectTargets(from: armies)
    attackTargets(targets)
    return true
}

func war(immuneBoost: Int) -> Army? {
    let inputFilePath = CommandLine.arguments[1]
    let input = try! String(contentsOfFile: inputFilePath, encoding: .utf8)

    let armies = parseArmies(from: input, immuneBoost: immuneBoost)
    var fightCount = 0
    var previousTotalUnits = 0
    // print(format(armies))
    // print("\nFinished \(fightCount) fights.\n")
    while fight(armies) {
        fightCount += 1

        let totalUnits = armies.flatMap { $0.groups }.map { $0.count }.reduce(0, +)
        if totalUnits == previousTotalUnits {
            break
        }
        previousTotalUnits = totalUnits

        //print("")
        //print(format(armies))
        //print("\nFinished \(fightCount) fights.\n")
    }

    let livingArmies = armies.filter { $0.isAlive }
    if livingArmies.count > 1 {
        return nil
    } else if let winner = armies.filter({ $0.isAlive }).first {
        return winner
    } else {
        // print("No one is left alive.")
        return nil
    }
}

if let winner = war(immuneBoost: 0) {
    let remainingUnits = winner.groups.map { $0.count }.reduce(0, +)
    print("Part 1: \(winner.name) wins with \(remainingUnits) remaining units.")
}

var winningBoosts = [Int]()
var winnersQueue = DispatchQueue(label: "winners")
DispatchQueue.concurrentPerform(iterations: 1000) { immuneBoost in
    let winner = war(immuneBoost: immuneBoost)
    if winner?.name == "Immune System" {
        winnersQueue.async {
            winningBoosts.append(immuneBoost)
        }
    }
}

if let boost = winningBoosts.min(), let winner = war(immuneBoost: boost) {
    let remainingUnits = winner.groups.map { $0.count }.reduce(0, +)
    print("Part 2: \(winner.name) wins with \(remainingUnits) remaining units.")
}
