//
//  day03.swift
//  AOC2020
//
//  Created by Arthur Dexter on 12/3/20.
//

import AdventOfCodeUtils
import Foundation

//--- Day 3: Toboggan Trajectory ---
//
//With the toboggan login problems resolved, you set off toward the airport. While travel by toboggan might be easy, it's certainly not safe: there's very minimal steering and the area is covered in trees. You'll need to see which angles will take you near the fewest trees.
//
//Due to the local geology, trees in this area only grow on exact integer coordinates in a grid. You make a map (your puzzle input) of the open squares (.) and trees (#) you can see. For example:
//
//..##.......
//#...#...#..
//.#....#..#.
//..#.#...#.#
//.#...##..#.
//..#.##.....
//.#.#.#....#
//.#........#
//#.##...#...
//#...##....#
//.#..#...#.#
//
//These aren't the only trees, though; due to something you read about once involving arboreal genetics and biome stability, the same pattern repeats to the right many times:
//
//..##.........##.........##.........##.........##.........##.......  --->
//#...#...#..#...#...#..#...#...#..#...#...#..#...#...#..#...#...#..
//.#....#..#..#....#..#..#....#..#..#....#..#..#....#..#..#....#..#.
//..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#
//.#...##..#..#...##..#..#...##..#..#...##..#..#...##..#..#...##..#.
//..#.##.......#.##.......#.##.......#.##.......#.##.......#.##.....  --->
//.#.#.#....#.#.#.#....#.#.#.#....#.#.#.#....#.#.#.#....#.#.#.#....#
//.#........#.#........#.#........#.#........#.#........#.#........#
//#.##...#...#.##...#...#.##...#...#.##...#...#.##...#...#.##...#...
//#...##....##...##....##...##....##...##....##...##....##...##....#
//.#..#...#.#.#..#...#.#.#..#...#.#.#..#...#.#.#..#...#.#.#..#...#.#  --->
//
//You start on the open square (.) in the top-left corner and need to reach the bottom (below the bottom-most row on your map).
//
//The toboggan can only follow a few specific slopes (you opted for a cheaper model that prefers rational numbers); start by counting all the trees you would encounter for the slope right 3, down 1:
//
//From your starting position at the top-left, check the position that is right 3 and down 1. Then, check the position that is right 3 and down 1 from there, and so on until you go past the bottom of the map.
//
//The locations you'd check in the above example are marked here with O where there was an open square and X where there was a tree:
//
//..##.........##.........##.........##.........##.........##.......  --->
//#..O#...#..#...#...#..#...#...#..#...#...#..#...#...#..#...#...#..
//.#....X..#..#....#..#..#....#..#..#....#..#..#....#..#..#....#..#.
//..#.#...#O#..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#
//.#...##..#..X...##..#..#...##..#..#...##..#..#...##..#..#...##..#.
//..#.##.......#.X#.......#.##.......#.##.......#.##.......#.##.....  --->
//.#.#.#....#.#.#.#.O..#.#.#.#....#.#.#.#....#.#.#.#....#.#.#.#....#
//.#........#.#........X.#........#.#........#.#........#.#........#
//#.##...#...#.##...#...#.X#...#...#.##...#...#.##...#...#.##...#...
//#...##....##...##....##...#X....##...##....##...##....##...##....#
//.#..#...#.#.#..#...#.#.#..#...X.#.#..#...#.#.#..#...#.#.#..#...#.#  --->
//
//In this example, traversing the map using this slope would cause you to encounter 7 trees.
//
//Starting at the top-left corner of your map and following a slope of right 3 and down 1, how many trees would you encounter?

func day03part01() throws {
    let map = try parseInput()
    let trees = treesEncountered(in: map, for: (right: 3, down: 1))
    print("Day 03, part 01: \(trees.count)") // 153
}

//--- Part Two ---
//
//Time to check the rest of the slopes - you need to minimize the probability of a sudden arboreal stop, after all.
//
//Determine the number of trees you would encounter if, for each of the following slopes, you start at the top-left corner and traverse the map all the way to the bottom:
//
//    Right 1, down 1.
//    Right 3, down 1. (This is the slope you already checked.)
//    Right 5, down 1.
//    Right 7, down 1.
//    Right 1, down 2.
//
//In the above example, these slopes would find 2, 7, 3, 4, and 2 tree(s) respectively; multiplied together, these produce the answer 336.
//
//What do you get if you multiply together the number of trees encountered on each of the listed slopes?


func day03part02() throws {
    let map = try parseInput()
    let slopes: [(right: Int, down: Int)] = [
        (right: 1, down: 1),
        (right: 3, down: 1),
        (right: 5, down: 1),
        (right: 7, down: 1),
        (right: 1, down: 2),
    ]
    let product = slopes
        .map { (slope: (right: Int, down: Int)) -> Int in
            treesEncountered(in: map, for: slope).count
        }
        .reduce(1, *)
    print("Day 03, part 02: \(product)")
}

private func treesEncountered(in map: [[Bool]], for slope: (right: Int, down: Int)) -> [Position] {
    var trees: [Position] = []
    var position = Position(x: 0, y: 0)
    while position.y < map.count {
        let normalizedPosition = position.normalized(in: map)
        if map[normalizedPosition.y][normalizedPosition.x] {
            trees.append(position)
        }
        position = Position(
            x: position.x + slope.right,
            y: position.y + slope.down
        )
    }
    return trees
}

private struct Position {
    let x: Int
    let y: Int

    func normalized(in map: [[Bool]]) -> Position {
        guard !map.isEmpty else { fatalError() }
        let newY = y % map.count
        let row = map[newY]
        guard !row.isEmpty else { fatalError() }
        let newX = x % row.count
        return Position(x: newX, y: newY)
    }
}

private func parseInput() throws -> [[Bool]] {
    let map = try readInput()
        .lines
        .map { (line: String) -> [Bool] in
            guard !line.isEmpty else {
                throw ParseError<String>("Empty row")
            }
            return line.map { (character: Character) -> Bool in
                character == "#"
            }
        }
    guard !map.isEmpty else {
        throw ParseError<String>("Empty map")
    }
    return map
}
