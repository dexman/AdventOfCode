import Foundation

struct Position: Hashable, CustomStringConvertible {
    let x: Int
    let y: Int

    var description: String {
        return "(\(x),\(y))"
    }

    var up: Position {
        return Position(x: x, y: y - 1)
    }

    var down: Position {
        return Position(x: x, y: y + 1)
    }

    var left: Position {
        return Position(x: x - 1, y: y)
    }

    var right: Position {
        return Position(x: x + 1, y: y)
    }
}

enum Water: Equatable {
    case flowing
    case steady
}

func parseClayTiles(from input: String) -> Set<Position> {
    let allVeins = input
      .replacingOccurrences(of: " ", with: "")
      .split(separator: "\n")
      .map { line -> (Range<Int>, Range<Int>) in
          let fields: [String: Range<Int>] = line
            .split(separator: ",")
            .map { $0.split(separator: "=").map { String($0) } }
            .reduce(into: [:]) { result, keyValue in
                result[keyValue[0]] = keyValue[1]
            }
            .mapValues { value in
                let valueRange = value
                  .replacingOccurrences(of: "..", with: ".")
                  .split(separator: ".")
                  .map { Int($0)! }
                return valueRange.first!..<(valueRange.last! + 1)
            }
          return (fields["x"]!, fields["y"]!)
      }
      .flatMap { xrange, yrange in
          yrange.flatMap { y in
              xrange.map { x in
                  return Position(x: x, y: y)
              }
          }
      }
    return Set(allVeins)
}

func scanBounds(of clayTiles: Set<Position>) -> (x: Range<Int>, y: Range<Int>) {
    let scanTopLeftX = (clayTiles.min { $0.x < $1.x }?.x ?? 0) - 2
    let scanTopLeftY = 0
    let scanBottomRightX = (clayTiles.max { $0.x < $1.x }?.x ?? 0) + 2
    let scanBottomRightY = clayTiles.max { $0.y < $1.y }?.y ?? 0
    return (
      x: scanTopLeftX..<(scanBottomRightX + 1),
      y: scanTopLeftY..<(scanBottomRightY + 1)
    )
}

func format(clayTiles: Set<Position>, spring: Position, waterTiles: [Position: Water]) -> String {
    let bounds = scanBounds(of: clayTiles)
    return "\n" + bounds.y.map { y in
        bounds.x.map { x in
            let position = Position(x: x, y: y)
            if position == spring {
                return "+"
            } else if clayTiles.contains(position) {
                assert(waterTiles[position] == nil)
                return "#"
            } else if let water = waterTiles[position] {
                switch water {
                case .flowing:
                    return "|"
                case .steady:
                    return "~"
                }
            } else {
                return "."
            }
        }.joined(separator: "")
    }.joined(separator: "\n")
}

let inputFilePath = CommandLine.arguments[1]
let input = try! String(contentsOfFile: inputFilePath, encoding: .utf8)
let springPosition = Position(x: 500, y: 0)
let clayTiles = parseClayTiles(from: input)
let (xRange, yRange) = scanBounds(of: clayTiles)
var waterTiles = [Position: Water]()

func canFlowDown(to position: Position) -> Bool {
    return
      yRange.contains(position.y) &&
      !clayTiles.contains(position) &&
      waterTiles[position] != .steady
}

func canFlowOut(to position: Position) -> Bool {
    return
      yRange.contains(position.y) &&
      !clayTiles.contains(position) &&
      waterTiles[position] != .steady
}

enum Operation: Equatable {
    case flowDown(Position)
    case flowOut(Position)
}

var queue = [Operation]()

func append(_ operation: Operation) {
    if !queue.contains(operation) {
        queue.append(operation)
    }
}

func flowDown(from position: Position) {
    var currentPosition = position
    while canFlowDown(to: currentPosition) {
        waterTiles[currentPosition] = .flowing
        currentPosition = currentPosition.down
    }

    if yRange.contains(currentPosition.y) {
        append(.flowOut(currentPosition.up))
    }
}

func flowOut(from position: Position) {
    var leftEnd = position
    while canFlowOut(to: leftEnd.left), !canFlowDown(to: leftEnd.down) {
        leftEnd = leftEnd.left
    }

    var rightEnd = position
    while canFlowOut(to: rightEnd.right), !canFlowDown(to: rightEnd.down) {
        rightEnd = rightEnd.right
    }

    if !canFlowOut(to: leftEnd.left), !canFlowOut(to: rightEnd.right) {
        var currentPositon = leftEnd
        while currentPositon.x <= rightEnd.x {
            waterTiles[currentPositon] = .steady
            currentPositon = currentPositon.right
        }
        append(.flowOut(position.up))
    } else {
        var currentPositon = leftEnd
        while currentPositon.x <= rightEnd.x {
            waterTiles[currentPositon] = .flowing
            currentPositon = currentPositon.right
        }
        if canFlowDown(to: leftEnd.down) {
            append(.flowDown(leftEnd))
        }
        if canFlowDown(to: rightEnd.down) {
            append(.flowDown(rightEnd))
        }
    }
}

// print(format(
//         clayTiles: clayTiles,
//         spring: springPosition,
//         waterTiles: waterTiles))

queue.append(.flowDown(springPosition))
while !queue.isEmpty {
    switch queue.removeFirst() {
    case .flowDown(let position):
        flowDown(from: position)
    case .flowOut(let position):
        flowOut(from: position)
    }
    // print(format(
    //     clayTiles: clayTiles,
    //     spring: springPosition,
    //     waterTiles: waterTiles))
}

print(format(
        clayTiles: clayTiles,
        spring: springPosition,
        waterTiles: waterTiles))

let scanTopY = clayTiles.min { $0.y < $1.y }?.y ?? 0
let scanBottomY = clayTiles.max { $0.y < $1.y }?.y ?? 0

let part1Count = waterTiles
  .keys
  .filter { $0.y >= scanTopY && $0.y <= scanBottomY }
  .count
print("Part 1: There are \(part1Count) water tiles.")

let part2Count = waterTiles
  .filter { _, water in water == .steady }
  .keys
  .filter { $0.y >= scanTopY && $0.y <= scanBottomY }
  .count
print("Part 2: There are \(part2Count) water tiles.")


// That's not the right answer; your answer is too high. If you're
// stuck, there are some general tips on the about page, or you can
// ask for hints on the subreddit. Please wait one minute before
// trying again. (You guessed 41032.) [Return to Day 17]
