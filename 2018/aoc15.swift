// --- Day 15: Beverage Bandits ---

// Having perfected their hot chocolate, the Elves have a new problem:
// the Goblins that live in these caves will do anything to steal
// it. Looks like they're here for a fight.

// You scan the area, generating a map of the walls (#), open cavern
// (.), and starting position of every Goblin (G) and Elf (E) (your
// puzzle input).

// Combat proceeds in rounds; in each round, each unit that is still
// alive takes a turn, resolving all of its actions before the next
// unit's turn begins. On each unit's turn, it tries to move into
// range of an enemy (if it isn't already) and then attack (if it is
// in range).

// All units are very disciplined and always follow very strict combat
// rules. Units never move or attack diagonally, as doing so would be
// dishonorable. When multiple choices are equally valid, ties are
// broken in reading order: top-to-bottom, then left-to-right. For
// instance, the order in which units take their turns within a round
// is the reading order of their starting positions in that round,
// regardless of the type of unit or whether other units have moved
// after the round started. For example:

//                  would take their
// These units:   turns in this order:
//   #######           #######
//   #.G.E.#           #.1.2.#
//   #E.G.E#           #3.4.5#
//   #.G.E.#           #.6.7.#
//   #######           #######

// Each unit begins its turn by identifying all possible targets
// (enemy units). If no targets remain, combat ends.

// Then, the unit identifies all of the open squares (.) that are in
// range of each target; these are the squares which are adjacent
// (immediately up, down, left, or right) to any target and which
// aren't already occupied by a wall or another unit. Alternatively,
// the unit might already be in range of a target. If the unit is not
// already in range of a target, and there are no open squares which
// are in range of a target, the unit ends its turn.

// If the unit is already in range of a target, it does not move, but
// continues its turn with an attack. Otherwise, since it is not in
// range of a target, it moves.

// To move, the unit first considers the squares that are in range and
// determines which of those squares it could reach in the fewest
// steps. A step is a single movement to any adjacent (immediately up,
// down, left, or right) open (.) square. Units cannot move into walls
// or other units. The unit does this while considering the current
// positions of units and does not do any prediction about where units
// will be later. If the unit cannot reach (find an open path to) any
// of the squares that are in range, it ends its turn. If multiple
// squares are in range and tied for being reachable in the fewest
// steps, the square which is first in reading order is chosen. For
// example:

// Targets:      In range:     Reachable:    Nearest:      Chosen:
// #######       #######       #######       #######       #######
// #E..G.#       #E.?G?#       #E.@G.#       #E.!G.#       #E.+G.#
// #...#.#  -->  #.?.#?#  -->  #.@.#.#  -->  #.!.#.#  -->  #...#.#
// #.G.#G#       #?G?#G#       #@G@#G#       #!G.#G#       #.G.#G#
// #######       #######       #######       #######       #######

// In the above scenario, the Elf has three targets (the three
// Goblins):

// - Each of the Goblins has open, adjacent squares which are in range
//   (marked with a ? on the map).
// - Of those squares, four are reachable (marked @); the other two
//   (on the right) would require moving through a wall or unit to
//   reach.
// - Three of these reachable squares are nearest, requiring the fewest
//   steps (only 2) to reach (marked !).
// - Of those, the square which is first in reading order is chosen
//   (+).

// The unit then takes a single step toward the chosen square along
// the shortest path to that square. If multiple steps would put the
// unit equally closer to its destination, the unit chooses the step
// which is first in reading order. (This requires knowing when there
// is more than one shortest path so that you can consider the first
// step of each such path.) For example:

// In range:     Nearest:      Chosen:       Distance:     Step:
// #######       #######       #######       #######       #######
// #.E...#       #.E...#       #.E...#       #4E212#       #..E..#
// #...?.#  -->  #...!.#  -->  #...+.#  -->  #32101#  -->  #.....#
// #..?G?#       #..!G.#       #...G.#       #432G2#       #...G.#
// #######       #######       #######       #######       #######

// The Elf sees three squares in range of a target (?), two of which
// are nearest (!), and so the first in reading order is chosen
// (+). Under "Distance", each open square is marked with its distance
// from the destination square; the two squares to which the Elf could
// move on this turn (down and to the right) are both equally good
// moves and would leave the Elf 2 steps from being in range of the
// Goblin. Because the step which is first in reading order is chosen,
// the Elf moves right one square.

// Here's a larger example of movement:

// Initially:
// #########
// #G..G..G#
// #.......#
// #.......#
// #G..E..G#
// #.......#
// #.......#
// #G..G..G#
// #########

// After 1 round:
// #########
// #.G...G.#
// #...G...#
// #...E..G#
// #.G.....#
// #.......#
// #G..G..G#
// #.......#
// #########

// After 2 rounds:
// #########
// #..G.G..#
// #...G...#
// #.G.E.G.#
// #.......#
// #G..G..G#
// #.......#
// #.......#
// #########

// After 3 rounds:
// #########
// #.......#
// #..GGG..#
// #..GEG..#
// #G..G...#
// #......G#
// #.......#
// #.......#
// #########

// Once the Goblins and Elf reach the positions above, they all are
// either in range of a target or cannot find any square in range of a
// target, and so none of the units can move until a unit dies.

// After moving (or if the unit began its turn in range of a target),
// the unit attacks.

// To attack, the unit first determines all of the targets that are in
// range of it by being immediately adjacent to it. If there are no
// such targets, the unit ends its turn. Otherwise, the adjacent
// target with the fewest hit points is selected; in a tie, the
// adjacent target with the fewest hit points which is first in
// reading order is selected.

// The unit deals damage equal to its attack power to the selected
// target, reducing its hit points by that amount. If this reduces its
// hit points to 0 or fewer, the selected target dies: its square
// becomes . and it takes no further turns.

// Each unit, either Goblin or Elf, has 3 attack power and starts with
// 200 hit points.

// For example, suppose the only Elf is about to attack:

//        HP:            HP:
// G....  9       G....  9  
// ..G..  4       ..G..  4  
// ..EG.  2  -->  ..E..     
// ..G..  2       ..G..  2  
// ...G.  1       ...G.  1  

// The "HP" column shows the hit points of the Goblin to the left in
// the corresponding row. The Elf is in range of three targets: the
// Goblin above it (with 4 hit points), the Goblin to its right (with
// 2 hit points), and the Goblin below it (also with 2 hit
// points). Because three targets are in range, the ones with the
// lowest hit points are selected: the two Goblins with 2 hit points
// each (one to the right of the Elf and one below the Elf). Of those,
// the Goblin first in reading order (the one to the right of the Elf)
// is selected. The selected Goblin's hit points (2) are reduced by
// the Elf's attack power (3), reducing its hit points to -1, killing
// it.

// After attacking, the unit's turn ends. Regardless of how the unit's
// turn ends, the next unit in the round takes its turn. If all units
// have taken turns in this round, the round ends, and a new round
// begins.

// The Elves look quite outnumbered. You need to determine the outcome
// of the battle: the number of full rounds that were completed (not
// counting the round in which combat ends) multiplied by the sum of
// the hit points of all remaining units at the moment combat
// ends. (Combat only ends when a unit finds no targets during its
// turn.)

// Below is an entire sample combat. Next to each map, each row's
// units' hit points are listed from left to right.

// Initially:
// #######   
// #.G...#   G(200)
// #...EG#   E(200), G(200)
// #.#.#G#   G(200)
// #..G#E#   G(200), E(200)
// #.....#   
// #######   

// After 1 round:
// #######   
// #..G..#   G(200)
// #...EG#   E(197), G(197)
// #.#G#G#   G(200), G(197)
// #...#E#   E(197)
// #.....#   
// #######   

// After 2 rounds:
// #######   
// #...G.#   G(200)
// #..GEG#   G(200), E(188), G(194)
// #.#.#G#   G(194)
// #...#E#   E(194)
// #.....#   
// #######   

// Combat ensues; eventually, the top Elf dies:

// After 23 rounds:
// #######   
// #...G.#   G(200)
// #..G.G#   G(200), G(131)
// #.#.#G#   G(131)
// #...#E#   E(131)
// #.....#   
// #######   

// After 24 rounds:
// #######   
// #..G..#   G(200)
// #...G.#   G(131)
// #.#G#G#   G(200), G(128)
// #...#E#   E(128)
// #.....#   
// #######   

// After 25 rounds:
// #######   
// #.G...#   G(200)
// #..G..#   G(131)
// #.#.#G#   G(125)
// #..G#E#   G(200), E(125)
// #.....#   
// #######   

// After 26 rounds:
// #######   
// #G....#   G(200)
// #.G...#   G(131)
// #.#.#G#   G(122)
// #...#E#   E(122)
// #..G..#   G(200)
// #######   

// After 27 rounds:
// #######   
// #G....#   G(200)
// #.G...#   G(131)
// #.#.#G#   G(119)
// #...#E#   E(119)
// #...G.#   G(200)
// #######   

// After 28 rounds:
// #######   
// #G....#   G(200)
// #.G...#   G(131)
// #.#.#G#   G(116)
// #...#E#   E(113)
// #....G#   G(200)
// #######   

// More combat ensues; eventually, the bottom Elf dies:

// After 47 rounds:
// #######   
// #G....#   G(200)
// #.G...#   G(131)
// #.#.#G#   G(59)
// #...#.#   
// #....G#   G(200)
// #######   

// Before the 48th round can finish, the top-left Goblin finds that
// there are no targets remaining, and so combat ends. So, the number
// of full rounds that were completed is 47, and the sum of the hit
// points of all remaining units is 200+131+59+200 = 590. From these,
// the outcome of the battle is 47 * 590 = 27730.

// Here are a few example summarized combats:

// #######       #######
// #G..#E#       #...#E#   E(200)
// #E#E.E#       #E#...#   E(197)
// #G.##.#  -->  #.E##.#   E(185)
// #...#E#       #E..#E#   E(200), E(200)
// #...E.#       #.....#
// #######       #######

// Combat ends after 37 full rounds
// Elves win with 982 total hit points left
// Outcome: 37 * 982 = 36334
// #######       #######   
// #E..EG#       #.E.E.#   E(164), E(197)
// #.#G.E#       #.#E..#   E(200)
// #E.##E#  -->  #E.##.#   E(98)
// #G..#.#       #.E.#.#   E(200)
// #..E#.#       #...#.#   
// #######       #######   

// Combat ends after 46 full rounds
// Elves win with 859 total hit points left
// Outcome: 46 * 859 = 39514
// #######       #######   
// #E.G#.#       #G.G#.#   G(200), G(98)
// #.#G..#       #.#G..#   G(200)
// #G.#.G#  -->  #..#..#   
// #G..#.#       #...#G#   G(95)
// #...E.#       #...G.#   G(200)
// #######       #######   

// Combat ends after 35 full rounds
// Goblins win with 793 total hit points left
// Outcome: 35 * 793 = 27755
// #######       #######   
// #.E...#       #.....#   
// #.#..G#       #.#G..#   G(200)
// #.###.#  -->  #.###.#   
// #E#G#G#       #.#.#.#   
// #...#G#       #G.G#G#   G(98), G(38), G(200)
// #######       #######   

// Combat ends after 54 full rounds
// Goblins win with 536 total hit points left
// Outcome: 54 * 536 = 28944
// #########       #########   
// #G......#       #.G.....#   G(137)
// #.E.#...#       #G.G#...#   G(200), G(200)
// #..##..G#       #.G##...#   G(200)
// #...##..#  -->  #...##..#   
// #...#...#       #.G.#...#   G(200)
// #.G...G.#       #.......#   
// #.....G.#       #.......#   
// #########       #########   

// Combat ends after 20 full rounds
// Goblins win with 937 total hit points left
// Outcome: 20 * 937 = 18740
// What is the outcome of the combat described in your puzzle input?

import Foundation

let inputFilePath = CommandLine.arguments[1]
let input = try! String(contentsOfFile: inputFilePath, encoding: .utf8)

enum MapTile {
    case wall
    case openCavern
}

struct Position: Hashable, Comparable, CustomStringConvertible {
    let x: Int
    let y: Int

    /// Adjacent means 1 tile directly up, down, left or right of the
    /// current position. Diagonals are NOT adjacent.
    func isAdjacent(to other: Position) -> Bool {
        return (abs(other.y - y) + abs(other.x - x)) == 1
    }

    /// Return positions adjacent to this one, some of which may not
    /// be valid on the current map.
    var adjacentPositions: [Position] {
        return [
          Position(x: x, y: y - 1),
          Position(x: x - 1, y: y),
          Position(x: x + 1, y: y),
          Position(x: x, y: y + 1),
        ]
    }

    var description: String {
        return "(\(x),\(y))"
    }


    /// Compare positions by "reading order".
    static func < (_ lhs: Position, _ rhs: Position) -> Bool {
        if lhs.y < rhs.y {
            return true
        } else if lhs.y == rhs.y {
            return lhs.x < rhs.x
        } else {
            return false
        }
    }
}

enum PlayerType {
    case goblin
    case elf
}

class Player {
    let type: PlayerType
    let attackPower: Int
    var hitPoints: Int
    var position: Position

    init(type: PlayerType, hitPoints: Int = 200, position: Position) {
        self.type = type
        self.attackPower = 3
        self.hitPoints = hitPoints
        self.position = position
    }

    func isEnemy(of other: Player) -> Bool {
        return type != other.type
    }

    func attack(_ other: Player) {
        if other.hitPoints > 0 {
            other.hitPoints -= attackPower
        }
    }
}

func parse(from input: String) -> ([[MapTile]], [Player]) {
    // Split the input into a 2-dimensional array of Characters.
    let grid: [[Character]] = input
      .split(separator: "\n")
      .map { line in line.map { $0 } }

    // Ensure all rows are the same length
    let rowCounts = grid.map { $0.count }
    assert(rowCounts.min() == rowCounts.max())

    let map = grid.map { row in
        row.map { tileCharacter -> MapTile in
            if tileCharacter == "#" {
                return .wall
            } else {
                return .openCavern
            }
        }
    }

    let players = grid.enumerated().flatMap { (y, row) in
        row.enumerated().compactMap { (x, playerChar) -> Player? in
            if playerChar == "G" {
                return Player(
                  type: .goblin,
                  position: Position(x: x, y: y))
            } else if playerChar == "E" {
                return Player(
                  type: .elf,
                  position: Position(x: x, y: y))
            } else {
                return nil
            }
        }
    }

    return (map, players)
}

func format(map: [[MapTile]], players: [Player]) -> String {
    func format(type: PlayerType) -> String {
        switch type {
        case .goblin:
            return "G"
        case .elf:
            return "E"
        }
    }

    let playersByPosition = [Position: Player](
      uniqueKeysWithValues: players.filter { $0.hitPoints > 0 }.map { ($0.position, $0) })

    return /*"\u{001b}[H\u{001b}[2J" +*/ map.enumerated().map { (y, row) in
        let rowMapString = row.enumerated().map { (x, tile) in
            switch tile {
            case .wall:
                return "#"
            case .openCavern:
                let position = Position(x: x, y: y)
                if let player = playersByPosition[position], player.hitPoints > 0 {
                    return format(type: player.type)
                } else {
                    return "."
                }
            }
        }.joined(separator: "")

        let rowPlayersString = players
          .filter { $0.position.y == y && $0.hitPoints > 0 }
          .sorted { $0.position < $1.position }
          .map { "\(format(type: $0.type))(\($0.hitPoints))" }
          .joined(separator: ",")

        return "\(rowMapString)    \(rowPlayersString)"
    }.joined(separator: "\n")
}

func canMove(to position: Position, in map: [[MapTile]], players: [Player]) -> Bool {
    guard
      position.y < map.count,
      position.x < map[position.y].count
    else {
        return false
    }

    switch map[position.y][position.x] {
    case .wall:
        return false
    case .openCavern:
        if players.contains(where: { $0.hitPoints > 0 && $0.position == position }) {
            return false
        } else {
            return true
        }
    }
}

extension Array where Element: Comparable {
    static func < (_ lhs: Array, _ rhs: Array) -> Bool {
        for (l, r) in zip(lhs, rhs) {
            if l < r {
                return true
            } else if l > r {
                return false
            }
        }
        return lhs.count < rhs.count
    }
}

func shortestPath2(from source: Position, to targets: Set<Position>, occupied: Set<Position>) -> [[Position]] {
    // The set of positions already evaluated
    var visited = occupied
    visited.remove(source)

    // The set of known nodes that are not yet evaluated.
    var queue = [(Int, [Position])]([(0, [source])])

    var results = [[Position]]()
    var best = Int.max

    while !queue.isEmpty {
        // print("queue=\(queue)")
        guard
          let (distance, path) = queue.min(by: { lhs, rhs in
              if lhs.0 < rhs.0 {
                  return true
              } else if lhs.0 == rhs.0 {
                  // Break ties with reading position
                  return lhs.1 < rhs.1
              } else {
                  return false
              }
          }),
          let current = path.last
        else {
            break
        }

        if path.count > best {
            return results
        }

        queue.removeAll { $0.0 == distance && $0.1 == path }

        // print("currentDistance=\(distance) currentPath=\(path)")

        if targets.contains(current) {
            // print("current==destination")
            results.append(path)
            best = min(best, path.count)
            continue
        }

        if visited.contains(current) {
            // print("already visited")
            continue
        }

        visited.insert(current)

        for neighbor in current.adjacentPositions {
            // print("neighbor=\(neighbor)")
            if visited.contains(neighbor) {
                // print("skipping neighbor, already evaluated")
            } else {
                queue.append((distance + 1, path + [neighbor]))
            }
        }
    }

    return results
}

func targetsAdjacent(to currentPlayer: Player, players: [Player]) -> [Player] {
    let adjacent = Set(currentPlayer.position.adjacentPositions)
    return players
      .filter {
          $0.hitPoints > 0 &&
            currentPlayer.isEnemy(of: $0) &&
            adjacent.contains($0.position)
      }
      .sorted { lhs, rhs -> Bool in
          if lhs.hitPoints < rhs.hitPoints {
              // Lowest hitPoints first
              return true
          } else if lhs.hitPoints == rhs.hitPoints {
              // Break ties in hitPoints by using position.
              return lhs.position < rhs.position
          } else {
              return false
          }
      }
}

func turn(for currentPlayer: Player, map: [[MapTile]], players: [Player]) -> Bool {
    guard currentPlayer.hitPoints > 0 else {
        return true
    }
    
    let targets = players.filter {
        $0.hitPoints > 0 && currentPlayer.isEnemy(of: $0)
    }
    guard !targets.isEmpty else {
        return false
    }

    if let target = targetsAdjacent(to: currentPlayer, players: players).first {
        // print("\(currentPlayer) attacking \(target)")
        currentPlayer.attack(target)
        return true
    } else {
        let destinations = targets
          .flatMap { $0.position.adjacentPositions }
          .filter { canMove(to: $0, in: map, players: players) }
        let uniqueDestinations = Set(destinations)
        // print("moving from \(currentPlayer.position) towards \(uniqueDestinations)")

        var occupied = Set<Position>(players.map { $0.position })
        for y in 0..<map.count {
            for x in 0..<map[y].count {
                if case .wall = map[y][x] {
                    occupied.insert(Position(x: x, y: y))
                }
            }
        }

        let shortestPaths = shortestPath2(
          from: currentPlayer.position,
          to: uniqueDestinations,
          occupied: occupied)
        let bestPath = shortestPaths
          .min { lhs, rhs in
              if lhs.count < rhs.count {
                  return true
              } else if lhs.count == rhs.count {
                  // Use reading order of steps when same length
                  guard lhs.count > 1 else { return false }
                  return lhs[1] < rhs[1]
              } else {
                  return false
              }
          }

        // print("paths=\n\(shortestPaths.map { "\($0)" }.joined(separator: "\n"))")
        currentPlayer.position = bestPath?.dropFirst().first ?? currentPlayer.position
        // print("moved to \(currentPlayer.position)")
        if let target = targetsAdjacent(to: currentPlayer, players: players).first {
            // print("\(currentPlayer) attacking \(target)")
            currentPlayer.attack(target)
            return true
        } else {
            // print("moved, nothing to attack around \(currentPlayer)")
            return true
        }
    }
}

let (map, players) = parse(from: input)

print("Initial:")
print(format(map: map, players: players))

var roundCount = 0
while true {
    var completedRound = false
    for player in players.sorted(by: { $0.position < $1.position }) {
        completedRound = turn(for: player, map: map, players: players)
        if !completedRound {
            break
        }
    }

    if completedRound {
        roundCount += 1
        print("\nAfter \(roundCount) rounds:")
        print(format(map: map, players: players))
    } else {
        break
    }
}

print("\nEnd:")
print(format(map: map, players: players))

if let winner = players.first {
    let remainingHitPoints = players
      .filter { $0.hitPoints > 0 }
      .map { $0.hitPoints }
      .reduce(0, +)
    print("Combat ends after \(roundCount) full rounds.")
    print("\(winner.type)s win with \(remainingHitPoints) total hit points left.")
    print("Outcome: \(roundCount * remainingHitPoints)")
} else {
    print("Combat ended with no winners.")
}

// 195774
// 37272
