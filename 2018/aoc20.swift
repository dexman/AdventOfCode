import Foundation

enum Direction: String {
    case north
    case east
    case south
    case west

    init?(_ character: Character) {
        switch character {
        case "N":
            self = .north
        case "E":
            self = .east
        case "S":
            self = .south
        case "W":
            self = .west
        default:
            return nil
        }
    }

    var opposite: Direction {
        switch self {
        case .north:
            return .south
        case .east:
            return .west
        case .south:
            return .north
        case .west:
            return .east
        }
    }
}

struct Coordinate: Hashable {
    let x: Int
    let y: Int

    func moved(_ direction: Direction) -> Coordinate {
        switch direction {
        case .north:
            return Coordinate(x: x, y: y - 1)
        case .east:
            return Coordinate(x: x + 1, y: y)
        case .south:
            return Coordinate(x: x, y: y + 1)
        case .west:
            return Coordinate(x: x - 1, y: y)
        }
    }
}

func parseRooms<S: StringProtocol>(from input: S) -> [Coordinate: Set<Direction>] {
    var roomStack = [Coordinate(x: 0, y: 0)]
    var rooms: [Coordinate: Set<Direction>] = [
      Coordinate(x: 0, y: 0): Set<Direction>(),
    ]
    for character in input {
        if let direction = Direction(character) {
            let current = roomStack.popLast()!
            rooms[current, default: Set<Direction>()].insert(direction)

            let nextRoom = current.moved(direction)
            roomStack.append(nextRoom)
            rooms[nextRoom, default: Set<Direction>()].insert(direction.opposite)
        } else if character == "(" {
            roomStack.append(roomStack.last!)
        } else if character == "|" {
            roomStack.removeLast()
            roomStack.append(roomStack.last!)
        } else if character == ")" {
            roomStack.removeLast()
        } else {
            // Ignore anything else
        }
    }
    return rooms
}

func format(_ rooms: [Coordinate: Set<Direction>]) -> String {
    let minX = rooms.keys.map { $0.x }.min() ?? 0
    let minY = rooms.keys.map { $0.y }.min() ?? 0
    let maxX = rooms.keys.map { $0.x }.max() ?? 0
    let maxY = rooms.keys.map { $0.y }.max() ?? 0

    let width = (maxX - minX + 1) * 2 + 1
    let header = String(repeating: "#", count: width) + "\n"
    
    return header + (minY...maxY).map { y in
        var horizontal = "#"
        var vertical = "#"
        for x in minX...maxX {
            if x == 0, y == 0 {
                horizontal += "X"
            } else {
                horizontal += "."
            }
            let coordinate = Coordinate(x: x, y: y)
            if rooms[coordinate]?.contains(.east) ?? false {
                horizontal += "|"
            } else {
                horizontal += "#"
            }

            if rooms[coordinate]?.contains(.south) ?? false {
                vertical += "-"
            } else {
                vertical += "#"
            }
            vertical += "#"
        }
        return "\(horizontal)\n\(vertical)"
    }.joined(separator: "\n")

}

func shortestPath(from source: Coordinate, to destination: Coordinate, in rooms: [Coordinate: Set<Direction>]) -> [Coordinate]? {
    // The set of positions already evaluated
    var visited = Set<Coordinate>()

    // The set of known paths that are not yet evaluated.
    var queue: [[Coordinate]] = [[source]]

    // var best = Int.max

    while !queue.isEmpty {
        // print("queue=\(queue)")
        guard
          let path = queue.min(by: { $0.count < $1.count }),
          let current = path.last
        else {
            break
        }

        // if path.count > best {
        //     return results
        // }

        queue = queue.filter { !$0.elementsEqual(path) }

        // print("currentDistance=\(distance) currentPath=\(path)")

        if current == destination {
            // print("current==destination")
            // results.append(path)
            // best = min(best, path.count)
            // continue
            return path
        }

        if visited.contains(current) {
            // print("already visited")
            continue
        }

        visited.insert(current)

        let neighbors = rooms[current]?.map { current.moved($0) } ?? []
        for neighbor in neighbors {
            // print("neighbor=\(neighbor)")
            if visited.contains(neighbor) {
                // print("skipping neighbor, already evaluated")
            } else {
                queue.append(path + [neighbor])
            }
        }
    }

    return nil
}

let inputFilePath = CommandLine.arguments[1]
let input = try! String(contentsOfFile: inputFilePath, encoding: .utf8)
let rooms = parseRooms(from: input)

print("Regex: \(input)")
print(format(rooms))
print("\nThere are \(rooms.keys.count) rooms to check.")

let origin = Coordinate(x: 0, y: 0)
let otherRooms = rooms.keys.filter { $0 != origin }

var pathLengths = [Int](repeating: Int.min, count: otherRooms.count)
let pathLengthsQueue = DispatchQueue(label: "pathLengths")

DispatchQueue.concurrentPerform(iterations: otherRooms.count) { index in
    let room = otherRooms[index]
    if let count = shortestPath(from: origin, to: room, in: rooms)?.count {
        pathLengthsQueue.async {
            pathLengths[index] = count - 1
        }
    }
}

let longestPathLength = pathLengths.max() ?? Int.min
print("Furthest room requires passing \(longestPathLength) doors.")

let longPathsCount = pathLengths.filter { $0 >= 1000 }.count
print("\(longPathsCount) rooms are at least 1000 doors away.")
