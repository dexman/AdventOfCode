// --- Day 3: No Matter How You Slice It ---

// The Elves managed to locate the chimney-squeeze prototype fabric
// for Santa's suit (thanks to someone who helpfully wrote its box IDs
// on the wall of the warehouse in the middle of the
// night). Unfortunately, anomalies are still affecting them - nobody
// can even agree on how to cut the fabric.

// The whole piece of fabric they're working on is a very large square
// - at least 1000 inches on each side.

// Each Elf has made a claim about which area of fabric would be ideal
// for Santa's suit. All claims have an ID and consist of a single
// rectangle with edges parallel to the edges of the fabric. Each
// claim's rectangle is defined as follows:

// The number of inches between the left edge of the fabric and the
// left edge of the rectangle.
// The number of inches between the top edge of the fabric and the top
// edge of the rectangle.
// The width of the rectangle in inches.
// The height of the rectangle in inches.

// A claim like #123 @ 3,2: 5x4 means that claim ID 123 specifies a
// rectangle 3 inches from the left edge, 2 inches from the top edge,
// 5 inches wide, and 4 inches tall. Visually, it claims the square
// inches of fabric represented by # (and ignores the square inches of
// fabric represented by .) in the diagram below:

// ...........
// ...........
// ...#####...
// ...#####...
// ...#####...
// ...#####...
// ...........
// ...........
// ...........

// The problem is that many of the claims overlap, causing two or more
// claims to cover part of the same areas. For example, consider the
// following claims:

// #1 @ 1,3: 4x4
// #2 @ 3,1: 4x4
// #3 @ 5,5: 2x2

// Visually, these claim the following areas:

// ........
// ...2222.
// ...2222.
// .11XX22.
// .11XX22.
// .111133.
// .111133.
// ........

// The four square inches marked with X are claimed by both 1 and
// 2. (Claim 3, while adjacent to the others, does not overlap either
// of them.)

// If the Elves all proceed with their own plans, none of them will
// have enough fabric. How many square inches of fabric are within two
// or more claims?

import Foundation

struct Point: Hashable {
    let x: Int
    let y: Int
}

struct Size {
    let width: Int
    let height: Int
}

struct Rect {
    let origin: Point
    let size: Size

    var x: Int {
        return origin.x
    }

    var maxX: Int {
        return origin.x + size.width
    }

    var y: Int {
        return origin.y
    }

    var maxY: Int {
        return origin.y + size.height
    }
}

extension Rect {
    init(x: Int, y: Int, width: Int, height: Int) {
        origin = Point(x: x, y: y)
        size = Size(width: width, height: height)
    }
}

let inputFilePath = CommandLine.arguments[1]
let input = (try? String(contentsOfFile: inputFilePath, encoding: .utf8)) ?? ""

let claims: [Rect] = input
  .split(separator: "\n")
  .map { line in
      let claimComponents = line
        .replacingOccurrences(
          of: "[#@,:x]",
          with: " ",
          options: [.regularExpression])
        .split(separator: " ")
        .map(String.init(_:))
        .compactMap(Int.init(_:))
      return Rect(
        x: claimComponents[1],
        y: claimComponents[2],
        width: claimComponents[3],
        height: claimComponents[4])
  }

var claimed = [Point: [Int]]()
for (index, claim) in claims.enumerated() {
    let id = index + 1
    for x in claim.x..<claim.maxX {
        for y in claim.y..<claim.maxY {
            claimed[Point(x: x, y: y), default: []].append(id)
        }
    }
}
let overlappingSquares = claimed.values.filter { $0.count > 1 }
print("Part 1 area overlapping=\(overlappingSquares.count)") // 120408

// --- Part Two ---

// Amidst the chaos, you notice that exactly one claim doesn't overlap
// by even a single square inch of fabric with any other claim. If you
// can somehow draw attention to it, maybe the Elves will be able to
// make Santa's suit after all!

// For example, in the claims above, only claim 3 is intact after all
// claims are made.

// What is the ID of the only claim that doesn't overlap?

let allIds = Set(claimed.values.flatMap { $0 })
let overlappingIds = Set(overlappingSquares.flatMap { $0 })
let uniqueClaimIds = allIds.subtracting(overlappingIds)
print("Part 2 non-overlapped claim ID=\(uniqueClaimIds)")
