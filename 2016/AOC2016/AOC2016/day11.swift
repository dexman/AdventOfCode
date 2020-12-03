//
//  day11.swift
//  AOC2016
//
//  Created by Arthur Dexter on 11/27/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import AdventOfCodeUtils
import Foundation

func day11() throws {
    let initialItems = try readInput()
        .lines
        .map(parseItems(from:))
    let initialState = State(items: initialItems, elevatorIndex: 0)

    let shortestPathPart1 = try findShortestPath(initialState: initialState).required()
    print("Day 11, part 01: Least number of moves=\(shortestPathPart1.count)")

    var initialItemsPart2 = initialItems
    initialItemsPart2[0].append(Item(itemType: .generator, elementType: ElementType.elementType(for: "elerium")))
    initialItemsPart2[0].append(Item(itemType: .microchip, elementType: ElementType.elementType(for: "elerium")))
    initialItemsPart2[0].append(Item(itemType: .generator, elementType: ElementType.elementType(for: "dilithium")))
    initialItemsPart2[0].append(Item(itemType: .microchip, elementType: ElementType.elementType(for: "dilithium")))
    let initialStatePart2 = State(items: initialItemsPart2, elevatorIndex: 0)

    let shortestPathPart2 = try findShortestPath(initialState: initialStatePart2).required()
    print("Day 11, part 02: Least number of moves=\(shortestPathPart2.count)")

}

private func findShortestPath(initialState: State) -> [State]? {
    var stack: [State] = [initialState]
    var bestPathToState: [State: [State]] = [initialState: []]
    var terminalPaths: Set<[State]> = []

    var step = 0
    while true {
        guard
            let currentState = stack.enumerated().min(by: { lhsArg, rhsArg in
                let (lhs, rhs) = (lhsArg.element, rhsArg.element)
                if lhs.distanceFromTerminal < rhs.distanceFromTerminal {
                    return true
                } else if lhs.distanceFromTerminal == rhs.distanceFromTerminal {
                    return bestPathToState[lhs, default: []].count < bestPathToState[rhs, default: []].count
                } else {
                    return false
                }
            }),
            let currentPath = bestPathToState[currentState.element]
        else {
            break
        }
        stack.remove(at: currentState.offset)

//        if step % 1000 == 0 {
//            print("Step=\(step) length=\(currentPath.count)\n\(currentState.element)")
//        }

        let nextStates = findNextStates(for: currentState.element)
        for nextState in nextStates {
            if currentPath.contains(nextState) {
                // No backtracking allowed.
                continue
            }

            let nextPath = currentPath + [nextState]
            if
                let bestPath = terminalPaths.min(by: { $0.count < $1.count }),
                (nextPath.count + nextState.distanceFromTerminal) >= bestPath.count
            {
                // This path isn't better than our best path.
                continue
            }

            if let bestPath = bestPathToState[nextState], nextPath.count >= bestPath.count {
                // This path isn't better than our best path to this state.
                continue
            }
            bestPathToState[nextState] = nextPath

            if nextState.isTerminal {
                print("Found a terminal path of length=\(nextPath.count)")
                terminalPaths.insert(nextPath)
                stack.removeAll()
                break
            } else {
                stack.append(nextState)
            }
        }

        step += 1
    }

   return terminalPaths.min(by: { $0.count < $1.count })
}

private func findNextStates(for currentState: State) -> [State] {
    // Find all the possible combinations of items that can be taken in the elevator.
    let adjacentItemCombinations = currentState.items[currentState.elevatorIndex]
        .combinations
        .filter { itemsCombination in
            switch itemsCombination.count {
            case 0:
                // Must have at least one item to move the elevator.
                return false
            case 1:
                return true
            case 2:
                return itemsCombination[0].isCompatible(with: itemsCombination[1])
            default:
                // At most two items will fit in the elevator.
                return false
            }
        }

    // Find the directions the elevator could move in
    let directions = [-1, 1].filter {
        let nextElevatorIndex = $0 + currentState.elevatorIndex
        return nextElevatorIndex >= 0 && nextElevatorIndex < currentState.items.count
    }

    // Find all possible moves given the items that can be taken in the elevator.
    return directions.flatMap { direction -> [State] in
        let nextElevatorIndex = direction + currentState.elevatorIndex
        return adjacentItemCombinations.compactMap { elevatorItems -> State? in
            var nextItems = currentState.items

            // Add items to next floor.
            nextItems[nextElevatorIndex].append(contentsOf: elevatorItems)

            // Remove items from prior floor.
            for item in elevatorItems {
                guard let index = nextItems[currentState.elevatorIndex].firstIndex(of: item) else {
                    fatalError()
                }
                nextItems[currentState.elevatorIndex].remove(at: index)
            }

            guard nextItems.allSatisfy({ $0.isCompatible }) else {
                return nil
            }

            return State(items: nextItems, elevatorIndex: nextElevatorIndex)
        }
    }
}

private func format(_ state: State) -> String {
    var lines: [String] = []
    for (floorIndex, floorItems) in state.items.enumerated() {
        var line = "F\(floorIndex + 1) "
        if state.elevatorIndex == floorIndex {
            line += "E  "
        } else {
            line += ".  "
        }
        for item in floorItems {
            line += "\(item) "
        }
        lines.append(line)
    }
    return lines.reversed().joined(separator: "\n")
}

private func parseItems<S: StringProtocol>(from string: S) throws -> [Item] {
    var items: [Item] = []

    let tokens = string
        .replacingOccurrences(of: ".", with: "")
        .replacingOccurrences(of: ",", with: "")
        .replacingOccurrences(of: "-compatible", with: "")
        .split(separator: " ")
    var index = tokens.startIndex + 1
    while index < tokens.endIndex {
        switch tokens[index] {
        case "microchip":
            let elementType = ElementType.elementType(for: tokens[index - 1])
            items.append(Item(itemType: .microchip, elementType: elementType))
        case "generator":
            let elementType = ElementType.elementType(for: tokens[index - 1])
            items.append(Item(itemType: .generator, elementType: elementType))
        default:
            break
        }
        index += 1
    }

    return items
}

private extension Sequence where Element == Item {

    var isCompatible: Bool {
        // Always safe if no generators are present
        var remainingGenerators = self.filter({ $0.itemType == .generator })
        if remainingGenerators.isEmpty {
            return true
        }

        // Ensure all microchips are protected.
        var unprotectedMicrohips = self.filter({ $0.itemType == .microchip })
        while let microchip = unprotectedMicrohips.popLast() {
            if let generatorIndex = remainingGenerators.firstIndex(where: { $0.elementType == microchip.elementType }) {
                remainingGenerators.remove(at: generatorIndex)
            } else {
                return false
            }
        }
        return true
    }
}

private struct State: Hashable, CustomDebugStringConvertible {
    let items: [[Item]]
    let elevatorIndex: Int

    let isTerminal: Bool
    let distanceFromTerminal: Int

    init(items: [[Item]], elevatorIndex: Int) {
        self.items = items.map { $0.sorted() }
        self.elevatorIndex = elevatorIndex

        self.isTerminal = self.items.dropLast().map { $0.count }.reduce(0, +) == 0

        var distance = 0
        for (floorIndex, floorItems) in self.items.enumerated() {
            let floorDistance = self.items.count - floorIndex - 1
            distance += Int(ceil(Double((floorDistance * floorItems.count) + (floorDistance * (floorItems.count - 1))) / 2))
        }
        self.distanceFromTerminal = distance
    }

    var debugDescription: String {
        return format(self)
    }

    func hash(into hasher: inout Hasher) {
        self.elevatorIndex.hash(into: &hasher)
        self.items.hash(into: &hasher)
    }

    static func == (_ lhs: State, _ rhs: State) -> Bool {
        return
            lhs.elevatorIndex == rhs.elevatorIndex &&
            lhs.items == rhs.items
    }
}

private struct Item: Comparable, CustomDebugStringConvertible, Hashable {

    let itemType: ItemType
    let elementType: ElementType

    func isCompatible(with other: Item) -> Bool {
        return self.itemType == other.itemType || self.elementType == other.elementType
    }

    var debugDescription: String {
        switch self.itemType {
        case .generator:
            return "G-\(self.elementType)"
        case .microchip:
            return "M-\(self.elementType)"
        }
    }

    static func < (lhs: Item, rhs: Item) -> Bool {
        if lhs.itemType < rhs.itemType {
            return true
        } else if lhs.itemType == rhs.itemType {
            return lhs.elementType < rhs.elementType
        } else {
            return false
        }
    }
}

private class ElementType: Hashable, Comparable, CustomDebugStringConvertible {

    static func elementType<S: StringProtocol>(for name: S) -> ElementType {
        let n = String(name)
        if let result = Objects[n] {
            return result
        } else {
            let result = ElementType(id: Objects.count, name: n)
            Objects[n] = result
            return result
        }
    }

    func hash(into hasher: inout Hasher) {
        self.id.hash(into: &hasher)
    }

    static func == (lhs: ElementType, rhs: ElementType) -> Bool {
        return lhs.id == rhs.id
    }

    static func < (lhs: ElementType, rhs: ElementType) -> Bool {
        return lhs.id < rhs.id
    }

    var debugDescription: String {
        return self.name
    }

    private static var Objects: [String: ElementType] = [:]

    private let id: Int
    private let name: String

    private init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

private enum ItemType: Hashable {

    case generator
    case microchip

    static func < (lhs: ItemType, rhs: ItemType) -> Bool {
        switch (lhs, rhs) {
        case (.generator, .microchip):
            return true
        case (.generator, .generator), (.microchip, .microchip), (.microchip, .generator):
            return false
        }
    }
}
