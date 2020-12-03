// --- Day 14: Chocolate Charts ---

// You finally have a chance to look at all of the produce moving
// around. Chocolate, cinnamon, mint, chili peppers, nutmeg,
// vanilla... the Elves must be growing these plants to make hot
// chocolate! As you realize this, you hear a conversation in the
// distance. When you go to investigate, you discover two Elves in
// what appears to be a makeshift underground kitchen/laboratory.

// The Elves are trying to come up with the ultimate hot chocolate
// recipe; they're even maintaining a scoreboard which tracks the
// quality score (0-9) of each recipe.

// Only two recipes are on the board: the first recipe got a score of
// 3, the second, 7. Each of the two Elves has a current recipe: the
// first Elf starts with the first recipe, and the second Elf starts
// with the second recipe.

// To create new recipes, the two Elves combine their current
// recipes. This creates new recipes from the digits of the sum of the
// current recipes' scores. With the current recipes' scores of 3 and
// 7, their sum is 10, and so two new recipes would be created: the
// first with score 1 and the second with score 0. If the current
// recipes' scores were 2 and 3, the sum, 5, would only create one
// recipe (with a score of 5) with its single digit.

// The new recipes are added to the end of the scoreboard in the order
// they are created. So, after the first round, the scoreboard is 3,
// 7, 1, 0.

// After all new recipes are added to the scoreboard, each Elf picks a
// new current recipe. To do this, the Elf steps forward through the
// scoreboard a number of recipes equal to 1 plus the score of their
// current recipe. So, after the first round, the first Elf moves
// forward 1 + 3 = 4 times, while the second Elf moves forward 1 + 7 =
// 8 times. If they run out of recipes, they loop back around to the
// beginning. After the first round, both Elves happen to loop around
// until they land on the same recipe that they had in the beginning;
// in general, they will move to different recipes.

// Drawing the first Elf as parentheses and the second Elf as square
// brackets, they continue this process:

// (3)[7]
// (3)[7] 1  0 
//  3  7  1 [0](1) 0 
//  3  7  1  0 [1] 0 (1)
// (3) 7  1  0  1  0 [1] 2 
//  3  7  1  0 (1) 0  1  2 [4]
//  3  7  1 [0] 1  0 (1) 2  4  5 
//  3  7  1  0 [1] 0  1  2 (4) 5  1 
//  3 (7) 1  0  1  0 [1] 2  4  5  1  5 
//  3  7  1  0  1  0  1  2 [4](5) 1  5  8 
//  3 (7) 1  0  1  0  1  2  4  5  1  5  8 [9]
//  3  7  1  0  1  0  1 [2] 4 (5) 1  5  8  9  1  6 
//  3  7  1  0  1  0  1  2  4  5 [1] 5  8  9  1 (6) 7 
//  3  7  1  0 (1) 0  1  2  4  5  1  5 [8] 9  1  6  7  7 
//  3  7 [1] 0  1  0 (1) 2  4  5  1  5  8  9  1  6  7  7  9 
//  3  7  1  0 [1] 0  1  2 (4) 5  1  5  8  9  1  6  7  7  9  2 

// The Elves think their skill will improve after making a few recipes
// (your puzzle input). However, that could take ages; you can speed
// this up considerably by identifying the scores of the ten recipes
// after that. For example:

// If the Elves think their skill will improve after making 9 recipes,
// the scores of the ten recipes after the first nine on the
// scoreboard would be 5158916779 (highlighted in the last line of the
// diagram).

// After 5 recipes, the scores of the next ten would be 0124515891.
// After 18 recipes, the scores of the next ten would be 9251071085.
// After 2018 recipes, the scores of the next ten would be 5941429882.

// What are the scores of the ten recipes immediately after the number
// of recipes in your puzzle input?

// Your puzzle input is 556061.

import Foundation

extension Int {
    var digits: [Int] {
        var result = [Int]()
        if self == 0 {
            result.append(0)
        } else {
            var value = self
            while value != 0 {
                result.append(value % 10)
                value /= 10
            }
        }
        return result.reversed()
    }
}

extension Collection where Element: Comparable {
    func index(of needle: [Element]) -> Index? {
        guard needle.count <= count else { return nil }
        return indices.first { i in
            let searchEndIndex = index(i, offsetBy: needle.count)
            guard searchEndIndex < endIndex else { return false }
            return self[i..<searchEndIndex].elementsEqual(needle)
        }
    }
}

func nextRecipes(recipes: inout [Int], recipeIndexes: inout [Int]) {
    // Sum the current recipes
    let recipesSum = recipeIndexes.map { recipes[$0] }.reduce(0, +)

    // Append the digits of the sum to the current list of recipes
    // This approach is way faster than using `Int.digits`.
    if recipesSum < 10 {
        recipes.append(recipesSum)
    } else {
        recipes.append(1)
        recipes.append(recipesSum % 10)
    }

    // Step current recipe indexes forward
    recipeIndexes = recipeIndexes.map {
        let steps = recipes[$0] + 1
        return ($0 + steps) % recipes.count
    }
}

func recipeScores(initialRecipes: [Int], initialRecipeIndexes: [Int], after afterCount: Int, count: Int) -> [Int] {
    let maxRecipesCount = afterCount + count
    
    var recipes = initialRecipes
    var recipeIndexes = initialRecipeIndexes
    while recipes.count < maxRecipesCount {
        nextRecipes(recipes: &recipes, recipeIndexes: &recipeIndexes)
    }

    return Array(recipes[afterCount..<maxRecipesCount])
}

func countRecipes(before digits: [Int], initialRecipes: [Int], initialRecipeIndexes: [Int]) -> Int? {
    var recipes = initialRecipes
    var recipeIndexes = initialRecipeIndexes
    while true {
        let recipesSuffixStart = max(0, recipes.count - digits.count - 2)
        let recipesSuffix = recipes[recipesSuffixStart..<recipes.count]
        if let index = recipesSuffix.index(of: digits) {
            return index
        }
        nextRecipes(recipes: &recipes, recipeIndexes: &recipeIndexes)
    }
}

let puzzleInput = 556061

let initialRecipes = [3, 7]
let initialRecipeIndexes = [0, 1]

let part1Scores = recipeScores(
  initialRecipes: initialRecipes,
  initialRecipeIndexes: initialRecipeIndexes,
  after: puzzleInput,
  count: 10)
print("Part 1 recipes: \(part1Scores.map { "\($0)" }.joined(separator: ""))")

// --- Part Two ---

// As it turns out, you got the Elves' plan backwards. They actually
// want to know how many recipes appear on the scoreboard to the left
// of the first recipes whose scores are the digits from your puzzle
// input.

// 51589 first appears after 9 recipes.
// 01245 first appears after 5 recipes.
// 92510 first appears after 18 recipes.
// 59414 first appears after 2018 recipes.

// How many recipes appear on the scoreboard to the left of the score
// sequence in your puzzle input?

let part2Count = countRecipes(
  before: puzzleInput.digits,
  initialRecipes: initialRecipes,
  initialRecipeIndexes: initialRecipeIndexes)
if let part2Count = part2Count {
    print("Part 2 count: \(part2Count)")
} else {
    print("Part 2 failed")
}
