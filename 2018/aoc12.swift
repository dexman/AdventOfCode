// --- Day 12: Subterranean Sustainability ---

// The year 518 is significantly more underground than your history
// books implied. Either that, or you've arrived in a vast cavern
// network under the North Pole.

// After exploring a little, you discover a long tunnel that contains
// a row of small pots as far as you can see to your left and right. A
// few of them contain plants - someone is trying to grow things in
// these geothermally-heated caves.

// The pots are numbered, with 0 in front of you. To the left, the
// pots are numbered -1, -2, -3, and so on; to the right, 1, 2,
// 3.... Your puzzle input contains a list of pots from 0 to the right
// and whether they do (#) or do not (.) currently contain a plant,
// the initial state. (No other pots currently contain plants.) For
// example, an initial state of #..##.... indicates that pots 0, 3,
// and 4 currently contain plants.

// Your puzzle input also contains some notes you find on a nearby
// table: someone has been trying to figure out how these plants
// spread to nearby pots. Based on the notes, for each generation of
// plants, a given pot has or does not have a plant based on whether
// that pot (and the two pots on either side of it) had a plant in the
// last generation. These are written as LLCRR => N, where L are pots
// to the left, C is the current pot being considered, R are the pots
// to the right, and N is whether the current pot will have a plant in
// the next generation. For example:

// A note like ..#.. => . means that a pot that contains a plant but
// with no plants within two pots of it will not have a plant in it
// during the next generation.

// A note like ##.## => . means that an empty pot with two plants on
// each side of it will remain empty in the next generation.

// A note like .##.# => # means that a pot has a plant in a given
// generation if, in the previous generation, there were plants in
// that pot, the one immediately to the left, and the one two pots to
// the right, but not in the ones immediately to the right and two to
// the left.

// It's not clear what these plants are for, but you're sure it's
// important, so you'd like to make sure the current configuration of
// plants is sustainable by determining what will happen after 20
// generations.

// For example, given the following input:

// initial state: #..#.#..##......###...###

// ...## => #
// ..#.. => #
// .#... => #
// .#.#. => #
// .#.## => #
// .##.. => #
// .#### => #
// #.#.# => #
// #.### => #
// ##.#. => #
// ##.## => #
// ###.. => #
// ###.# => #
// ####. => #

// For brevity, in this example, only the combinations which do
// produce a plant are listed. (Your input includes all possible
// combinations.) Then, the next 20 generations will look like this:

//                  1         2         3     
//        0         0         0         0     
//  0: ...#..#.#..##......###...###...........
//  1: ...#...#....#.....#..#..#..#...........
//  2: ...##..##...##....#..#..#..##..........
//  3: ..#.#...#..#.#....#..#..#...#..........
//  4: ...#.#..#...#.#...#..#..##..##.........
//  5: ....#...##...#.#..#..#...#...#.........
//  6: ....##.#.#....#...#..##..##..##........
//  7: ...#..###.#...##..#...#...#...#........
//  8: ...#....##.#.#.#..##..##..##..##.......
//  9: ...##..#..#####....#...#...#...#.......
// 10: ..#.#..#...#.##....##..##..##..##......
// 11: ...#...##...#.#...#.#...#...#...#......
// 12: ...##.#.#....#.#...#.#..##..##..##.....
// 13: ..#..###.#....#.#...#....#...#...#.....
// 14: ..#....##.#....#.#..##...##..##..##....
// 15: ..##..#..#.#....#....#..#.#...#...#....
// 16: .#.#..#...#.#...##...#...#.#..##..##...
// 17: ..#...##...#.#.#.#...##...#....#...#...
// 18: ..##.#.#....#####.#.#.#...##...##..##..
// 19: .#..###.#..#.#.#######.#.#.#..#.#...#..
// 20: .#....##....#####...#######....#.#..##.

// The generation is shown along the left, where 0 is the initial
// state. The pot numbers are shown along the top, where 0 labels the
// center pot, negative-numbered pots extend to the left, and positive
// pots extend toward the right. Remember, the initial state begins at
// pot 0, which is not the leftmost pot used in this example.

// After one generation, only seven plants remain. The one in pot 0
// matched the rule looking for ..#.., the one in pot 4 matched the
// rule looking for .#.#., pot 9 matched .##.., and so on.

// In this example, after 20 generations, the pots shown as # contain
// plants, the furthest left of which is pot -2, and the furthest
// right of which is pot 34. Adding up all the numbers of
// plant-containing pots after the 20th generation produces 325.

// After 20 generations, what is the sum of the numbers of all pots
// which contain a plant?

import Foundation

func runOneGeneration(state: Set<Int>, rules: [UInt8: Bool]) -> Set<Int> {
    func pots(around index: Int) -> UInt8 {
        var result: UInt8 = 0
        ((index - 2)...(index + 2)).forEach { stateIndex in
            result = result << 1
            if state.contains(stateIndex) {
                result = result | 1
            }
        }
        return result
    }

    let potIndexMin = state.min() ?? 0
    let potIndexMax = state.max() ?? 0
    return Set(((potIndexMin - 3)...(potIndexMax + 3))
      .filter { potIndex in
          let potsAroundIndex = pots(around: potIndex)
          return rules[potsAroundIndex] ?? false
      })
}

func parseState(from string: String) -> Set<Int> {
    let indices = string
      .map { $0 == "#" }
      .enumerated()
      .filter { $0.1 }
      .map { $0.0 }
    return Set(indices)
}

func formatState(_ state: Set<Int>) -> String {
    let minIndex = min(state.min() ?? 0, 0)
    let maxIndex = max(minIndex, state.max() ?? 0)
    return (minIndex...maxIndex).map {
        let pot = state.contains($0) ? "#" : "."
        if $0 == 0 {
            return "][\(pot)"
        } else {
            return pot
        }
    }.joined(separator: "")
}

func describe(generation: Int, state: Set<Int>) -> String {
    let generationString = String(format: "%2d", generation)
    let potsString = formatState(state)
    return "\(generationString): \(potsString)"
}

let inputFilePath = CommandLine.arguments[1]
let input = try! String(contentsOfFile: inputFilePath, encoding: .utf8)
let lines = input.split(separator: "\n").filter { !$0.isEmpty }.map { String($0) }

let initialState: Set<Int> = Set(lines
  .filter { $0.starts(with: "initial state: ") }
  .map { $0.replacingOccurrences(of: "initial state: ", with: "") }
  .map { parseState(from: $0) }
  .first ?? [])

let ruleValues: [(UInt8, Bool)] = lines
  .filter { $0.contains(" => ") }
  .map { $0.replacingOccurrences(of: " => ", with: "\t") }
  .map { ruleString in
      let keyValue = ruleString.split(separator: "\t")
      var pattern: UInt8 = 0
      for pot in keyValue[0] {
          pattern = pattern << 1
          if pot == "#" {
              pattern = pattern | 1
          }
      }
      let replacement = keyValue[1] == "#"
      return (pattern, replacement)
  }
let rules = [UInt8: Bool](uniqueKeysWithValues: ruleValues)

var state = initialState
print(describe(generation: 0, state: state))
for generation in 1...20 {
    state = runOneGeneration(state: state, rules: rules)
    print(describe(generation: generation, state: state))
}

print("Part 1 sum: \(state.reduce(0, +))")

// --- Part Two ---

// You realize that 20 generations aren't enough. After all, these
// plants will need to last another 1500 years to even reach your
// timeline, not to mention your future.

// After fifty billion (50000000000) generations, what is the sum of
// the numbers of all pots which contain a plant?

let part2GenerationsCount = 50_000_000_000

var previousSum = 0
var previousSumDifference = 0
var previousSumRunLength = 0
var generation = 1

state = initialState
while generation < part2GenerationsCount {
    state = runOneGeneration(state: state, rules: rules)
    let sum = state.reduce(0, +)
    let difference = sum - previousSum
    if difference == previousSumDifference {
        previousSumRunLength += 1
        if previousSumRunLength == 1000 {
            break
        }
    } else {
        previousSumRunLength = 0
    }
    previousSum = sum
    previousSumDifference = difference
    generation += 1
}

let remainingGenerations = part2GenerationsCount - generation
let remainingGenerationsSum = remainingGenerations * previousSumDifference
let part2Sum = state.reduce(0, +) + remainingGenerationsSum
print("Part 2 sum: \(part2Sum)")
