// --- Day 9: Marble Mania ---

// You talk to the Elves while you wait for your navigation system to
// initialize. To pass the time, they introduce you to their favorite
// marble game.

// The Elves play this game by taking turns arranging the marbles in a
// circle according to very particular rules. The marbles are numbered
// starting with 0 and increasing by 1 until every marble has a
// number.

// First, the marble numbered 0 is placed in the circle. At this
// point, while it contains only a single marble, it is still a
// circle: the marble is both clockwise from itself and
// counter-clockwise from itself. This marble is designated the
// current marble.

// Then, each Elf takes a turn placing the lowest-numbered remaining
// marble into the circle between the marbles that are 1 and 2 marbles
// clockwise of the current marble. (When the circle is large enough,
// this means that there is one marble between the marble that was
// just placed and the current marble.) The marble that was just
// placed then becomes the current marble.

// However, if the marble that is about to be placed has a number
// which is a multiple of 23, something entirely different
// happens. First, the current player keeps the marble they would have
// placed, adding it to their score. In addition, the marble 7 marbles
// counter-clockwise from the current marble is removed from the
// circle and also added to the current player's score. The marble
// located immediately clockwise of the marble that was removed
// becomes the new current marble.

// For example, suppose there are 9 players. After the marble with
// value 0 is placed in the middle, each player (shown in square
// brackets) takes a turn. The result of each of those turns would
// produce circles of marbles like this, where clockwise is to the
// right and the resulting current marble is in parentheses:

// [-] (0)
// [1]  0 (1)
// [2]  0 (2) 1 
// [3]  0  2  1 (3)
// [4]  0 (4) 2  1  3 
// [5]  0  4  2 (5) 1  3 
// [6]  0  4  2  5  1 (6) 3 
// [7]  0  4  2  5  1  6  3 (7)
// [8]  0 (8) 4  2  5  1  6  3  7 
// [9]  0  8  4 (9) 2  5  1  6  3  7 
// [1]  0  8  4  9  2(10) 5  1  6  3  7 
// [2]  0  8  4  9  2 10  5(11) 1  6  3  7 
// [3]  0  8  4  9  2 10  5 11  1(12) 6  3  7 
// [4]  0  8  4  9  2 10  5 11  1 12  6(13) 3  7 
// [5]  0  8  4  9  2 10  5 11  1 12  6 13  3(14) 7 
// [6]  0  8  4  9  2 10  5 11  1 12  6 13  3 14  7(15)
// [7]  0(16) 8  4  9  2 10  5 11  1 12  6 13  3 14  7 15 
// [8]  0 16  8(17) 4  9  2 10  5 11  1 12  6 13  3 14  7 15 
// [9]  0 16  8 17  4(18) 9  2 10  5 11  1 12  6 13  3 14  7 15 
// [1]  0 16  8 17  4 18  9(19) 2 10  5 11  1 12  6 13  3 14  7 15 
// [2]  0 16  8 17  4 18  9 19  2(20)10  5 11  1 12  6 13  3 14  7 15 
// [3]  0 16  8 17  4 18  9 19  2 20 10(21) 5 11  1 12  6 13  3 14  7 15 
// [4]  0 16  8 17  4 18  9 19  2 20 10 21  5(22)11  1 12  6 13  3 14  7 15 
// [5]  0 16  8 17  4 18(19) 2 20 10 21  5 22 11  1 12  6 13  3 14  7 15 
// [6]  0 16  8 17  4 18 19  2(24)20 10 21  5 22 11  1 12  6 13  3 14  7 15 
// [7]  0 16  8 17  4 18 19  2 24 20(25)10 21  5 22 11  1 12  6 13  3 14  7 15

// The goal is to be the player with the highest score after the last
// marble is used up. Assuming the example above ends after the marble
// numbered 25, the winning score is 23+9=32 (because player 5 kept
// marble 23 and removed marble 9, while no other player got any
// points in this very short example game).

// Here are a few more examples:

// 10 players; last marble is worth 1618 points: high score is 8317
// 13 players; last marble is worth 7999 points: high score is 146373
// 17 players; last marble is worth 1104 points: high score is 2764
// 21 players; last marble is worth 6111 points: high score is 54718
// 30 players; last marble is worth 5807 points: high score is 37305

// What is the winning Elf's score?

import Foundation

let inputFilePath = CommandLine.arguments[1]
let input = try! String(contentsOfFile: inputFilePath, encoding: .utf8)
let lettersAndWhitespaces = CharacterSet.letters.union(.whitespacesAndNewlines)
let inputNumbers = input
  .filter {
      !$0.unicodeScalars.contains {
          lettersAndWhitespaces.contains($0)
      }
  }
  .split(separator: ";")
  .map { Int($0)! }
let numberOfPlayers = inputNumbers[0]
let lastMarbleValue = inputNumbers[1]

class Marble {
    let value: Int
    var next: Marble?
    var previous: Marble?

    init(value: Int, next: Marble? = nil, previous: Marble? = nil) {
        self.value = value
        self.next = next
        self.previous = previous
    }
}

func describeList(playerIndex: Int, _ marble: Marble) -> String {
    var startingMarble = marble.next
    while startingMarble !== marble && startingMarble?.value != 0 {
        startingMarble = startingMarble?.next
    }

    var components = [String]()
    var currentMarble = startingMarble
    while true {
        if currentMarble === marble {
            components.append("(\(currentMarble?.value ?? -1))")
        } else {
            components.append("\(currentMarble?.value ?? -1)")
        }
        currentMarble = currentMarble?.next
        if currentMarble === startingMarble {
            break
        }
    }
    return "[\(playerIndex + 1)] \(components.joined(separator: " "))"
}

func simulate(numberOfPlayers: Int, lastMarbleValue: Int) -> Int {
    var currentMarble = Marble(value: 0)
    currentMarble.next = currentMarble
    currentMarble.previous = currentMarble

    var nextMarbleValue = 1

    var scores = [Int](repeating: 0, count: numberOfPlayers)

    while nextMarbleValue <= lastMarbleValue {
        var playerIndex = 0
        while playerIndex < numberOfPlayers && nextMarbleValue <= lastMarbleValue {
            if nextMarbleValue % 23 == 0 {
                scores[playerIndex] += nextMarbleValue

                guard let marbleToRemove = currentMarble.previous?.previous?.previous?.previous?.previous?.previous?.previous else {
                    assert(false)
                }
                marbleToRemove.previous?.next = marbleToRemove.next
                marbleToRemove.next?.previous = marbleToRemove.previous
                scores[playerIndex] += marbleToRemove.value

                if let nextMarble = marbleToRemove.next {
                    currentMarble = nextMarble
                } else {
                    assert(false)
                }
            } else {
                let insertionPoint = currentMarble.next?.next
                let newMarble = Marble(
                  value: nextMarbleValue,
                  next: insertionPoint,
                  previous: insertionPoint?.previous)
                newMarble.previous?.next = newMarble
                insertionPoint?.previous = newMarble
                currentMarble = newMarble
            }

            playerIndex += 1
            nextMarbleValue += 1
        }
    }

    return scores.max() ?? 0
}

let part1Score = simulate(numberOfPlayers: numberOfPlayers, lastMarbleValue: lastMarbleValue)
print("Part 1 max score: \(part1Score)")

// --- Part Two ---

// Amused by the speed of your answer, the Elves are curious:

// What would the new winning Elf's score be if the number of the last
// marble were 100 times larger?

let part2Score = simulate(numberOfPlayers: numberOfPlayers, lastMarbleValue: 100 * lastMarbleValue)
print("Part 2 max score: \(part2Score)")

// [-] (0)
// [1] 0 (1)
// [2] 0 (2) 1
// [3] 0 2 1 (3)
// [4] 0 (4) 2 1 3
// [5] 0 4 2 (5) 1 3
// [6] 0 4 2 5 1 (6) 3
// [7] 0 4 2 5 1 6 3 (7)
// [8] 0 (8) 4 2 5 1 6 3 7
// [9] 0 8 4 (9) 2 5 1 6 3 7
// [1] 0 8 4 9 2 (10) 5 1 6 3 7
// [2] 0 8 4 9 2 10 5 (11) 1 6 3 7
// [3] 0 8 4 9 2 10 5 11 1 (12) 6 3 7
// [4] 0 8 4 9 2 10 5 11 1 12 6 (13) 3 7
// [5] 0 8 4 9 2 10 5 11 1 12 6 13 3 (14) 7
// [6] 0 8 4 9 2 10 5 11 1 12 6 13 3 14 7 (15)
// [7] 0 (16) 8 4 9 2 10 5 11 1 12 6 13 3 14 7 15
// [8] 0 16 8 (17) 4 9 2 10 5 11 1 12 6 13 3 14 7 15
// [9] 0 16 8 17 4 (18) 9 2 10 5 11 1 12 6 13 3 14 7 15
// [1] 0 16 8 17 4 18 9 (19) 2 10 5 11 1 12 6 13 3 14 7 15
// [2] 0 16 8 17 4 18 9 19 2 (20) 10 5 11 1 12 6 13 3 14 7 15
// [3] 0 16 8 17 4 18 9 19 2 20 10 (21) 5 11 1 12 6 13 3 14 7 15
// [4] 0 16 8 17 4 18 9 19 2 20 10 21 5 (22) 11 1 12 6 13 3 14 7 15
// [5] 0 16 8 17 4 18 9 19 2 20 10 21 5 22 (11) 1 12 6 13 3 14 7 15
// [6] 0 16 8 17 4 18 9 19 2 20 10 21 5 22 11 1 (24) 12 6 13 3 14 7 15
// [7] 0 16 8 17 4 18 9 19 2 20 10 21 5 22 11 1 24 12 (25) 6 13 3 14 7 15
