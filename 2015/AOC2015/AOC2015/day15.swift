//
//  day15.swift
//  AOC2015
//
//  Created by Arthur Dexter on 11/21/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import Foundation

func day15() throws {
    let ingredients = try readInput(day: 15).lines.map(parseIngredient(from:))

    var recipes: [[Int]] = []
    recipeCombinations(numberOfIngredients: ingredients.count, results: &recipes)

    let scoresPart1 = recipes.map { score(recipe: $0, ingredients: ingredients) }
    guard let maxScorePart1 = scoresPart1.max() else {
        throw NSError(domain: "day15", code: 0, userInfo: nil)
    }
    print("Day 15, part 01: Max score=\(maxScorePart1)")

    let recipesPart2 = recipes.filter {
        calories(recipe: $0, ingredients: ingredients) == 500
    }
    let scoresPart2 = recipesPart2.map { score(recipe: $0, ingredients: ingredients) }
    guard let maxScorePart2 = scoresPart2.max() else {
        throw NSError(domain: "day15", code: 0, userInfo: nil)
    }
    print("Day 15, part 02: Max score=\(maxScorePart2)")
}

private func calories(recipe: [Int], ingredients: [Ingredient]) -> Int {
    var calories = 0
    for (amount, ingredient) in zip(recipe, ingredients) {
        calories += amount * ingredient.calories
    }
    return calories
}

private func score(recipe: [Int], ingredients: [Ingredient]) -> Int {
    var capacity = 0
    for (amount, ingredient) in zip(recipe, ingredients) {
        capacity += amount * ingredient.capacity
    }
    capacity = max(capacity, 0)

    var durability = 0
    for (amount, ingredient) in zip(recipe, ingredients) {
        durability += amount * ingredient.durability
    }
    durability = max(durability, 0)

    var flavor = 0
    for (amount, ingredient) in zip(recipe, ingredients) {
        flavor += amount * ingredient.flavor
    }
    flavor = max(flavor, 0)

    var texture = 0
    for (amount, ingredient) in zip(recipe, ingredients) {
        texture += amount * ingredient.texture
    }
    texture = max(texture, 0)

    return capacity * durability * flavor * texture
}

private func recipeCombinations(numberOfIngredients: Int, remaining: Int = 100, path: [Int] = [], results: inout [[Int]]) {
    if path.count == numberOfIngredients - 1 {
        results.append(path + [remaining])
        return
    } else if path.count < numberOfIngredients - 1 {
        for i in 0...remaining {
            recipeCombinations(
                numberOfIngredients: numberOfIngredients,
                remaining: remaining - i,
                path: path + [i],
                results: &results)
        }
    }
}

private func parseIngredient<S: StringProtocol>(from string: S) throws -> Ingredient {
    let nameValues = string.split(separator: ":")
    guard nameValues.count == 2 else {
        throw ParseError<Ingredient>(string)
    }

    let values = nameValues[1]
        .replacingOccurrences(of: ",", with: "")
        .split(separator: " ")
        .compactMap { Int($0) }
    guard values.count == 5 else {
        throw ParseError<Ingredient>(nameValues[1])
    }

    return Ingredient(
        name: String(nameValues[0]),
        capacity: values[0],
        durability: values[1],
        flavor: values[2],
        texture: values[3],
        calories: values[4])
}

private struct Ingredient {
    let name: String
    let capacity: Int
    let durability: Int
    let flavor: Int
    let texture: Int
    let calories: Int
}
