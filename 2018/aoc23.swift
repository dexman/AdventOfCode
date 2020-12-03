// --- Day 23: Experimental Emergency Teleportation ---

// Using your torch to search the darkness of the rocky cavern, you
// finally locate the man's friend: a small reindeer.

// You're not sure how it got so far in this cave. It looks sick - too
// sick to walk - and too heavy for you to carry all the way
// back. Sleighs won't be invented for another 1500 years, of course.

// The only option is experimental emergency teleportation.

// You hit the "experimental emergency teleportation" button on the
// device and push I accept the risk on no fewer than 18 different
// warning messages. Immediately, the device deploys hundreds of tiny
// nanobots which fly around the cavern, apparently assembling
// themselves into a very specific formation. The device lists the
// X,Y,Z position (pos) for each nanobot as well as its signal radius
// (r) on its tiny screen (your puzzle input).

// Each nanobot can transmit signals to any integer coordinate which
// is a distance away from it less than or equal to its signal radius
// (as measured by Manhattan distance). Coordinates a distance away of
// less than or equal to a nanobot's signal radius are said to be in
// range of that nanobot.

// Before you start the teleportation process, you should determine
// which nanobot is the strongest (that is, which has the largest
// signal radius) and then, for that nanobot, the total number of
// nanobots that are in range of it, including itself.

// For example, given the following nanobots:

// pos=<0,0,0>, r=4
// pos=<1,0,0>, r=1
// pos=<4,0,0>, r=3
// pos=<0,2,0>, r=1
// pos=<0,5,0>, r=3
// pos=<0,0,3>, r=1
// pos=<1,1,1>, r=1
// pos=<1,1,2>, r=1
// pos=<1,3,1>, r=1

// The strongest nanobot is the first one (position 0,0,0) because its
// signal radius, 4 is the largest. Using that nanobot's location and
// signal radius, the following nanobots are in or out of range:

// The nanobot at 0,0,0 is distance 0 away, and so it is in range.
// The nanobot at 1,0,0 is distance 1 away, and so it is in range.
// The nanobot at 4,0,0 is distance 4 away, and so it is in range.
// The nanobot at 0,2,0 is distance 2 away, and so it is in range.
// The nanobot at 0,5,0 is distance 5 away, and so it is not in range.
// The nanobot at 0,0,3 is distance 3 away, and so it is in range.
// The nanobot at 1,1,1 is distance 3 away, and so it is in range.
// The nanobot at 1,1,2 is distance 4 away, and so it is in range.
// The nanobot at 1,3,1 is distance 5 away, and so it is not in range.

// In this example, in total, 7 nanobots are in range of the nanobot
// with the largest signal radius.

// Find the nanobot with the largest signal radius. How many nanobots
// are in range of its signals?

import Foundation

struct Coordinate: Hashable {
    let x: Int
    let y: Int
    let z: Int

    func manhattanDistance(to other: Coordinate) -> Int {
        return abs(other.z - z) + abs(other.y - y) + abs(other.x - x)
    }
}

struct Nanobot: Hashable {
    let coordinate: Coordinate
    let range: Int
}

func parseNanobots(from input: String) -> [Nanobot] {
    return input
      .split(separator: "\n")
      .map { line in
          let numbers = line
            .replacingOccurrences(of: "pos=<", with:"")
            .replacingOccurrences(of: ">, r=", with:",")
            .split(separator: ",")
            .map { Int($0)! }
          return Nanobot(
            coordinate: Coordinate(
              x: numbers[0],
              y: numbers[1],
              z: numbers[2]),
            range: numbers[3])
      }
}

let inputFilePath = CommandLine.arguments[1]
let input = try! String(contentsOfFile: inputFilePath, encoding: .utf8)
let bots = parseNanobots(from: input)

print("Go")

// guard let strongestBot = bots.max(by: { $0.range < $1.range }) else {
//     print("Could not find the strongest nanobot.")
//     exit(0)
// }

// let botsInRangeOfStrongest = bots.filter {
//     let distance = strongestBot.coordinate.manhattanDistance(
//       to: $0.coordinate)
//     return distance <= strongestBot.range
// }
// print("Part 1: \(botsInRangeOfStrongest.count) nanobots in range.")

// --- Part Two ---

// Now, you just need to figure out where to position yourself so that
// you're actually teleported when the nanobots activate.

// To increase the probability of success, you need to find the
// coordinate which puts you in range of the largest number of
// nanobots. If there are multiple, choose one closest to your
// position (0,0,0, measured by manhattan distance).

// For example, given the following nanobot formation:

// pos=<10,12,12>, r=2
// pos=<12,14,12>, r=2
// pos=<16,12,12>, r=4
// pos=<14,14,14>, r=6
// pos=<50,50,50>, r=200
// pos=<10,10,10>, r=5

// Many coordinates are in range of some of the nanobots in this
// formation. However, only the coordinate 12,12,12 is in range of the
// most nanobots: it is in range of the first five, but is not in
// range of the nanobot at 10,10,10. (All other coordinates are in
// range of fewer than five nanobots.) This coordinate's distance from
// 0,0,0 is 36.

// Find the coordinates that are in range of the largest number of
// nanobots. What is the shortest manhattan distance between any of
// those points and 0,0,0?

var results = [Set<Nanobot>]()
func BronKerbosch1(_ R: Set<Nanobot>, _ P: Set<Nanobot>, _ X: Set<Nanobot>) {
    func N(_ v: Nanobot) -> Set<Nanobot> {
       let neighbors = bots.filter {
           let distance = v.coordinate.manhattanDistance(
             to: $0.coordinate)
           return distance <= v.range
       }
       return Set(neighbors)
    }

    var P = P
    var X = X
    if P.isEmpty, X.isEmpty {
        // report R as a maximal clique
        results.append(R)
    }
    for v in P {
        let n = N(v)
        BronKerbosch1(R.union(Set([v])), P.intersection(n), X.intersection(n))
        P.remove(v)
        X.insert(v)
    }
}

func BronKerbosch1b() {
    func N(_ v: Nanobot) -> Set<Nanobot> {
       let neighbors = bots.filter {
           let distance = v.coordinate.manhattanDistance(
             to: $0.coordinate)
           return distance <= v.range
       }
       return Set(neighbors)
    }

    var stack = [(R: Set<Nanobot>, P: Set<Nanobot>, X: Set<Nanobot>)]()
    stack.append((Set<Nanobot>(), Set(bots), Set<Nanobot>()))

    while let item = stack.popLast() {
        let R = item.R
        var P = item.P
        var X = item.X

        if P.isEmpty, X.isEmpty {
            // report R as a maximal clique
            results.append(R)
        }
        for v in P {
            let n = N(v)
            stack.append((R.union(Set([v])), P.intersection(n), X.intersection(n)))
            P.remove(v)
            X.insert(v)
        }
    }
}

BronKerbosch1b()
print(results)
