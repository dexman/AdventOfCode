// --- Day 10: The Stars Align ---

// It's no use; your navigation system simply isn't capable of
// providing walking directions in the arctic circle, and certainly
// not in 1018.

// The Elves suggest an alternative. In times like these, North Pole
// rescue operations will arrange points of light in the sky to guide
// missing Elves back to base. Unfortunately, the message is easy to
// miss: the points move slowly enough that it takes hours to align
// them, but have so much momentum that they only stay aligned for a
// second. If you blink at the wrong time, it might be hours before
// another message appears.

// You can see these points of light floating in the distance, and
// record their position in the sky and their velocity, the relative
// change in position per second (your puzzle input). The coordinates
// are all given from your perspective; given enough time, those
// positions and velocities will move the points into a cohesive
// message!

// Rather than wait, you decide to fast-forward the process and
// calculate what the points will eventually spell.

// For example, suppose you note the following points:

// position=< 9,  1> velocity=< 0,  2>
// position=< 7,  0> velocity=<-1,  0>
// position=< 3, -2> velocity=<-1,  1>
// position=< 6, 10> velocity=<-2, -1>
// position=< 2, -4> velocity=< 2,  2>
// position=<-6, 10> velocity=< 2, -2>
// position=< 1,  8> velocity=< 1, -1>
// position=< 1,  7> velocity=< 1,  0>
// position=<-3, 11> velocity=< 1, -2>
// position=< 7,  6> velocity=<-1, -1>
// position=<-2,  3> velocity=< 1,  0>
// position=<-4,  3> velocity=< 2,  0>
// position=<10, -3> velocity=<-1,  1>
// position=< 5, 11> velocity=< 1, -2>
// position=< 4,  7> velocity=< 0, -1>
// position=< 8, -2> velocity=< 0,  1>
// position=<15,  0> velocity=<-2,  0>
// position=< 1,  6> velocity=< 1,  0>
// position=< 8,  9> velocity=< 0, -1>
// position=< 3,  3> velocity=<-1,  1>
// position=< 0,  5> velocity=< 0, -1>
// position=<-2,  2> velocity=< 2,  0>
// position=< 5, -2> velocity=< 1,  2>
// position=< 1,  4> velocity=< 2,  1>
// position=<-2,  7> velocity=< 2, -2>
// position=< 3,  6> velocity=<-1, -1>
// position=< 5,  0> velocity=< 1,  0>
// position=<-6,  0> velocity=< 2,  0>
// position=< 5,  9> velocity=< 1, -2>
// position=<14,  7> velocity=<-2,  0>
// position=<-3,  6> velocity=< 2, -1>

// Each line represents one point. Positions are given as <X, Y>
// pairs: X represents how far left (negative) or right (positive) the
// point appears, while Y represents how far up (negative) or down
// (positive) the point appears.

// At 0 seconds, each point has the position given. Each second, each
// point's velocity is added to its position. So, a point with
// velocity <1, -2> is moving to the right, but is moving upward twice
// as quickly. If this point's initial position were <3, 9>, after 3
// seconds, its position would become <6, 3>.

// Over time, the points listed above would move like this:

// Initially:
// ........#.............
// ................#.....
// .........#.#..#.......
// ......................
// #..........#.#.......#
// ...............#......
// ....#.................
// ..#.#....#............
// .......#..............
// ......#...............
// ...#...#.#...#........
// ....#..#..#.........#.
// .......#..............
// ...........#..#.......
// #...........#.........
// ...#.......#..........

// After 1 second:
// ......................
// ......................
// ..........#....#......
// ........#.....#.......
// ..#.........#......#..
// ......................
// ......#...............
// ....##.........#......
// ......#.#.............
// .....##.##..#.........
// ........#.#...........
// ........#...#.....#...
// ..#...........#.......
// ....#.....#.#.........
// ......................
// ......................

// After 2 seconds:
// ......................
// ......................
// ......................
// ..............#.......
// ....#..#...####..#....
// ......................
// ........#....#........
// ......#.#.............
// .......#...#..........
// .......#..#..#.#......
// ....#....#.#..........
// .....#...#...##.#.....
// ........#.............
// ......................
// ......................
// ......................

// After 3 seconds:
// ......................
// ......................
// ......................
// ......................
// ......#...#..###......
// ......#...#...#.......
// ......#...#...#.......
// ......#####...#.......
// ......#...#...#.......
// ......#...#...#.......
// ......#...#...#.......
// ......#...#..###......
// ......................
// ......................
// ......................
// ......................

// After 4 seconds:
// ......................
// ......................
// ......................
// ............#.........
// ........##...#.#......
// ......#.....#..#......
// .....#..##.##.#.......
// .......##.#....#......
// ...........#....#.....
// ..............#.......
// ....#......#...#......
// .....#.....##.........
// ...............#......
// ...............#......
// ......................
// ......................

// After 3 seconds, the message appeared briefly: HI. Of course, your
// message will be much longer and will take many more seconds to
// appear.

// What message will eventually appear in the sky?

import Foundation

let inputFilePath = CommandLine.arguments[1]
let input = try! String(contentsOfFile: inputFilePath, encoding: .utf8)

let numberRegex = try! NSRegularExpression(pattern: "[-\\d]+")

struct Point: Hashable {
    let x: Int
    let y: Int
}

struct Velocity {
    let x: Int
    let y: Int
}

struct Star {
    let point: Point
    let velocity: Velocity
}

func bounds(of stars: [Star]) -> (topLeft: Point, bottomRight: Point) {
    let topLeft = Point(
      x: stars.min { $0.point.x < $1.point.x }?.point.x ?? 0,
      y: stars.min { $0.point.y < $1.point.y }?.point.y ?? 0)
    let bottomRight = Point(
      x: stars.max { $0.point.x < $1.point.x }?.point.x ?? 0,
      y: stars.max { $0.point.y < $1.point.y }?.point.y ?? 0)
    return (topLeft, bottomRight)
}

func render(points: [Point]) -> String {
    let topLeft = Point(
      x: points.min { $0.x < $1.x }?.x ?? 0,
      y: points.min { $0.y < $1.y }?.y ?? 0)
    let bottomRight = Point(
      x: points.max { $0.x < $1.x }?.x ?? 0,
      y: points.max { $0.y < $1.y }?.y ?? 0)
    let pointsSet = Set(points)
    return (topLeft.y...bottomRight.y).map { y in
        return (topLeft.x...bottomRight.x).map { x in
            if pointsSet.contains(Point(x: x, y: y)) {
                return "█"
            } else {
                return " "
            }
        }.joined(separator: "")
    }.joined(separator: "\n")
}

func simulateSecond(_ stars: [Star]) -> [Star] {
    return stars.map { star in
        Star(
          point: Point(
            x: star.point.x + star.velocity.x,
            y: star.point.y + star.velocity.y),
          velocity: star.velocity)
    }
}

let inputStars = input
  .split(separator: "\n")
  .map { String($0) }
  .map { line -> Star in
      let numbers = numberRegex
        .matches(in: line, range: NSMakeRange(0, line.count))
        .map { Range($0.range, in: line)! }
        .map { Int(line[$0])! }
      assert(numbers.count == 4)
      return Star(
        point: Point(x: numbers[0], y: numbers[1]),
        velocity: Velocity(x: numbers[2], y: numbers[3]))
  }

var stars = inputStars
var seconds = 0
var previousArea = Int.max
while true {
    let newStars = simulateSecond(stars)
    let (topLeft, bottomRight) = bounds(of: newStars)
    let width = bottomRight.x - topLeft.x
    let height = bottomRight.y - topLeft.y
    let area = width * height

    if area > previousArea {
        let rendered = render(points: stars.map { $0.point })
        print(rendered)
        print("Took \(seconds) seconds.")
        break
    }

    stars = newStars
    previousArea = area
    seconds += 1
}
