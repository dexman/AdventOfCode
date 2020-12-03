import Foundation

struct Point: Hashable {
    let x: Int
    let y: Int
    let z: Int
    let t: Int

    func distance(to other: Point) -> Int {
        let xd: Int = abs(other.x - x)
        let yd: Int = abs(other.y - y)
        let zd: Int = abs(other.z - z)
        let td: Int = abs(other.t - t)
        return xd + yd + zd + td
    }
}

func constellations(of points: [Point]) -> [Set<Point>] {
    var stack = points

    var visited = Set<Point>()

    var constellations = [Set<Point>]()
    var constellationIndexByPoint = [Point: Int]()

    while let point = stack.popLast() {
        if visited.contains(point) {
            continue
        }
        visited.insert(point)

        let neighbors = Set(points.filter { other in
            point != other && point.distance(to: other) <= 3
        })

        let neighborConstellationIndex = constellationIndexByPoint
          .first { otherPoint, _ in
              neighbors.contains(otherPoint)
          }
          .map { $1 }

        let index: Int
        if let neighborConstellationIndex = neighborConstellationIndex {
            index = neighborConstellationIndex
        } else {
            constellations.append(Set<Point>())
            index = constellations.count - 1
        }

        constellations[index].insert(point)
        constellations[index].formUnion(neighbors)
        constellationIndexByPoint[point] = index
        for neighbor in neighbors {
            constellationIndexByPoint[neighbor] = index
        }

        stack.append(contentsOf: neighbors)
    }
    
    return constellations
}

let inputFilePath = CommandLine.arguments[1]
let input = try! String(contentsOfFile: inputFilePath, encoding: .utf8)

let points: [Point] = input
  .split(separator: "\n")
  .map { line in
      let values = line
        .split(separator: ",")
        .map { Int($0)! }
      return Point(
        x: values[0],
        y: values[1],
        z: values[2],
        t: values[3])
  }

print("Part 1: Number of constellations: \(constellations(of: points).count)")

