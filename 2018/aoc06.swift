// --- Day 6: Chronal Coordinates ---

// The device on your wrist beeps several times, and once again you
// feel like you're falling.

// "Situation critical," the device announces. "Destination
// indeterminate. Chronal interference detected. Please specify new
// target coordinates."

// The device then produces a list of coordinates (your puzzle
// input). Are they places it thinks are safe or dangerous? It
// recommends you check manual page 729. The Elves did not give you a
// manual.

// If they're dangerous, maybe you can minimize the danger by finding
// the coordinate that gives the largest distance from the other
// points.

// Using only the Manhattan distance, determine the area around each
// coordinate by counting the number of integer X,Y locations that are
// closest to that coordinate (and aren't tied in distance to any
// other coordinate).

// Your goal is to find the size of the largest area that isn't
// infinite. For example, consider the following list of coordinates:

// 1, 1
// 1, 6
// 8, 3
// 3, 4
// 5, 5
// 8, 9

// If we name these coordinates A through F, we can draw them on a
// grid, putting 0,0 at the top left:

// ..........
// .A........
// ..........
// ........C.
// ...D......
// .....E....
// .B........
// ..........
// ..........
// ........F.

// This view is partial - the actual grid extends infinitely in all
// directions. Using the Manhattan distance, each location's closest
// coordinate can be determined, shown here in lowercase:

// aaaaa.cccc
// aAaaa.cccc
// aaaddecccc
// aadddeccCc
// ..dDdeeccc
// bb.deEeecc
// bBb.eeee..
// bbb.eeefff
// bbb.eeffff
// bbb.ffffFf

// Locations shown as . are equally far from two or more coordinates,
// and so they don't count as being closest to any.

// In this example, the areas of coordinates A, B, C, and F are
// infinite - while not shown here, their areas extend forever outside
// the visible grid. However, the areas of coordinates D and E are
// finite: D is closest to 9 locations, and E is closest to 17 (both
// including the coordinate's location itself). Therefore, in this
// example, the size of the largest area is 17.

// What is the size of the largest area that isn't infinite?

import Foundation

let inputFilePath = CommandLine.arguments[1]
let input = try! String(contentsOfFile: inputFilePath, encoding: .utf8)

struct Coordinate: Hashable {
    let x: Int
    let y: Int

    func manhattanDistance(from other: Coordinate) -> Int {
        return abs(other.x - x) + abs(other.y - y)
    }
}

let coordinates: [Coordinate] = input
  .replacingOccurrences(of: " ", with: "")
  .split(separator: "\n")
  .map { line in
      let coordinate = line.split(separator: ",").map { Int($0)! }
      return Coordinate(x: coordinate[0], y: coordinate[1])
  }

let maxX = coordinates.max { $0.x < $1.x }?.x ?? 0
let maxY = coordinates.max { $0.y < $1.y }?.y ?? 0
var areas = [Coordinate: Set<Coordinate>]()
for y in 0...maxY {
    for x in 0...maxX {
        let coordinate = Coordinate(x: x, y: y)
        let closestCoordinates: [(coordinate: Coordinate, distance: Int)] = coordinates
          .map { (coordinate: $0, distance: $0.manhattanDistance(from: coordinate)) }
          .sorted { $0.distance < $1.distance }
        if closestCoordinates.count > 1, closestCoordinates[0].distance < closestCoordinates[1].distance {
            let closestCoordinate = closestCoordinates[0].coordinate
            areas[closestCoordinate, default: Set<Coordinate>()].insert(coordinate)
        }
    }
}

let finiteAreas = areas.filter { owner, coordinates in
    let allCoordinates = coordinates.union(Set([owner]))
    return allCoordinates.allSatisfy { coordinate in
        coordinate.x > 0 &&
          coordinate.x < maxX &&
          coordinate.y > 0 &&
          coordinate.y < maxY
    }
}

if let largestFiniteArea = finiteAreas.max(by: { $0.1.count < $1.1.count }) {
    print("Part 1 largest finite area is \(largestFiniteArea.1.count).")
} else {
    print("Part 1 no finite areas.")
}

// --- Part Two ---

// On the other hand, if the coordinates are safe, maybe the best you
// can do is try to find a region near as many coordinates as
// possible.

// For example, suppose you want the sum of the Manhattan distance to
// all of the coordinates to be less than 32. For each location, add
// up the distances to all of the given coordinates; if the total of
// those distances is less than 32, that location is within the
// desired region. Using the same coordinates as above, the resulting
// region looks like this:

// ..........
// .A........
// ..........
// ...###..C.
// ..#D###...
// ..###E#...
// .B.###....
// ..........
// ..........
// ........F.

// In particular, consider the highlighted location 4,3 located at the
// top middle of the region. Its calculation is as follows, where
// abs() is the absolute value function:

// Distance to coordinate A: abs(4-1) + abs(3-1) =  5
// Distance to coordinate B: abs(4-1) + abs(3-6) =  6
// Distance to coordinate C: abs(4-8) + abs(3-3) =  4
// Distance to coordinate D: abs(4-3) + abs(3-4) =  2
// Distance to coordinate E: abs(4-5) + abs(3-5) =  3
// Distance to coordinate F: abs(4-8) + abs(3-9) = 10
// Total distance: 5 + 6 + 4 + 2 + 3 + 10 = 30

// Because the total distance to all coordinates (30) is less than 32,
// the location is within the region.

// This region, which also includes coordinates D and E, has a total
// size of 16.

// Your actual region will need to be much larger than this example,
// though, instead including all locations with a total distance of
// less than 10000.

// What is the size of the region containing all locations which have
// a total distance to all given coordinates of less than 10000?


var part2Area = Set<Coordinate>()
for y in 0...maxY {
    for x in 0...maxX {
        let coordinate = Coordinate(x: x, y: y)
        let totalDistance = coordinates.reduce(0) { total, otherCoordinate in
            total + otherCoordinate.manhattanDistance(from: coordinate)
        }
        if totalDistance < 10000 {
            part2Area.insert(coordinate)
        }
    }
}

print("Part 2 area is \(part2Area.count).")
