// --- Day 13: Mine Cart Madness ---

// A crop of this size requires significant logistics to transport
// produce, soil, fertilizer, and so on. The Elves are very busy
// pushing things around in carts on some kind of rudimentary system
// of tracks they've come up with.

// Seeing as how cart-and-track systems don't appear in recorded
// history for another 1000 years, the Elves seem to be making this up
// as they go along. They haven't even figured out how to avoid
// collisions yet.

// You map out the tracks (your puzzle input) and see where you can
// help.

// Tracks consist of straight paths (| and -), curves (/ and \), and
// intersections (+). Curves connect exactly two perpendicular pieces
// of track; for example, this is a closed loop:

// /----\
// |    |
// |    |
// \----/

// Intersections occur when two perpendicular paths cross. At an
// intersection, a cart is capable of turning left, turning right, or
// continuing straight. Here are two loops connected by two
// intersections:

// /-----\
// |     |
// |  /--+--\
// |  |  |  |
// \--+--/  |
//    |     |
//    \-----/

// Several carts are also on the tracks. Carts always face either up
// (^), down (v), left (<), or right (>). (On your initial map, the
// track under each cart is a straight path matching the direction the
// cart is facing.)

// Each time a cart has the option to turn (by arriving at any
// intersection), it turns left the first time, goes straight the
// second time, turns right the third time, and then repeats those
// directions starting again with left the fourth time, straight the
// fifth time, and so on. This process is independent of the
// particular intersection at which the cart has arrived - that is,
// the cart has no per-intersection memory.

// Carts all move at the same speed; they take turns moving a single
// step at a time. They do this based on their current location: carts
// on the top row move first (acting from left to right), then carts
// on the second row move (again from left to right), then carts on
// the third row, and so on. Once each cart has moved one step, the
// process repeats; each of these loops is called a tick.

// For example, suppose there are two carts on a straight track:

// |  |  |  |  |
// v  |  |  |  |
// |  v  v  |  |
// |  |  |  v  X
// |  |  ^  ^  |
// ^  ^  |  |  |
// |  |  |  |  |

// First, the top cart moves. It is facing down (v), so it moves down
// one square. Second, the bottom cart moves. It is facing up (^), so
// it moves up one square. Because all carts have moved, the first
// tick ends. Then, the process repeats, starting with the first
// cart. The first cart moves down, then the second cart moves up -
// right into the first cart, colliding with it! (The location of the
// crash is marked with an X.) This ends the second and last tick.

// Here is a longer example:

// /->-\        
// |   |  /----\
// | /-+--+-\  |
// | | |  | v  |
// \-+-/  \-+--/
//   \------/   

// /-->\        
// |   |  /----\
// | /-+--+-\  |
// | | |  | |  |
// \-+-/  \->--/
//   \------/   

// /---v        
// |   |  /----\
// | /-+--+-\  |
// | | |  | |  |
// \-+-/  \-+>-/
//   \------/   

// /---\        
// |   v  /----\
// | /-+--+-\  |
// | | |  | |  |
// \-+-/  \-+->/
//   \------/   

// /---\        
// |   |  /----\
// | /->--+-\  |
// | | |  | |  |
// \-+-/  \-+--^
//   \------/   

// /---\        
// |   |  /----\
// | /-+>-+-\  |
// | | |  | |  ^
// \-+-/  \-+--/
//   \------/   

// /---\        
// |   |  /----\
// | /-+->+-\  ^
// | | |  | |  |
// \-+-/  \-+--/
//   \------/   

// /---\        
// |   |  /----<
// | /-+-->-\  |
// | | |  | |  |
// \-+-/  \-+--/
//   \------/   

// /---\        
// |   |  /---<\
// | /-+--+>\  |
// | | |  | |  |
// \-+-/  \-+--/
//   \------/   

// /---\        
// |   |  /--<-\
// | /-+--+-v  |
// | | |  | |  |
// \-+-/  \-+--/
//   \------/   

// /---\        
// |   |  /-<--\
// | /-+--+-\  |
// | | |  | v  |
// \-+-/  \-+--/
//   \------/   

// /---\        
// |   |  /<---\
// | /-+--+-\  |
// | | |  | |  |
// \-+-/  \-<--/
//   \------/   

// /---\        
// |   |  v----\
// | /-+--+-\  |
// | | |  | |  |
// \-+-/  \<+--/
//   \------/   

// /---\        
// |   |  /----\
// | /-+--v-\  |
// | | |  | |  |
// \-+-/  ^-+--/
//   \------/   

// /---\        
// |   |  /----\
// | /-+--+-\  |
// | | |  X |  |
// \-+-/  \-+--/
//   \------/   

// After following their respective paths for a while, the carts
// eventually crash. To help prevent crashes, you'd like to know the
// location of the first crash. Locations are given in X,Y
// coordinates, where the furthest left column is X=0 and the furthest
// top row is Y=0:

//            111
//  0123456789012
// 0/---\        
// 1|   |  /----\
// 2| /-+--+-\  |
// 3| | |  X |  |
// 4\-+-/  \-+--/
// 5  \------/   

// In this example, the location of the first crash is 7,3.

import Foundation

let inputFilePath = CommandLine.arguments[1]
let input = try! String(contentsOfFile: inputFilePath, encoding: .utf8)

enum Track {
    // Intersection, all 4 directions possible
    case intersection
    
    // Up & down
    case straightVertical

    // Left & right
    case straightHorizontal

    // Curve, terminals on upper & right edges
    case curveUpRight

    // Curve, terminals on upper & left edges
    case curveUpLeft

    // Curve, terminals on lower & right edges
    case curveDownRight

    // Curve, terminals on lower & left edges
    case curveDownLeft
}

enum TurnDirection {
    case left
    case straight
    case right

    var next: TurnDirection {
        switch self {
        case .left:
            return .straight
        case .straight:
            return .right
        case .right:
            return .left
        }
    }
}

enum CartDirection {
    case up
    case down
    case left
    case right

    func turned(_ direction: TurnDirection) -> CartDirection {
        switch direction {
        case .left:
            switch self {
            case .up:
                return .left
            case .down:
                return .right
            case .left:
                return .down
            case .right:
                return .up
            }
        case .straight:
            return self
        case .right:
            switch self {
            case .up:
                return .right
            case .down:
                return .left
            case .left:
                return .up
            case .right:
                return .down
            }
        }
    }
}

struct Position: Equatable, Comparable {
    let x: Int
    let y: Int

    static func == (lhs: Position, rhs: Position) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }

    static func < (lhs: Position, rhs: Position) -> Bool {
        if lhs.y < rhs.y {
            return true
        } else if lhs.y == rhs.y {
            return lhs.x < rhs.x
        } else {
            return false
        }
    }
}

struct Cart {
    let position: Position
    let direction: CartDirection
    let nextTurnDirection: TurnDirection
    let isCrashed: Bool

    init(position: Position, direction: CartDirection, nextTurnDirection: TurnDirection = .left, isCrashed: Bool = false) {
        self.position = position
        self.direction = direction
        self.nextTurnDirection = nextTurnDirection
        self.isCrashed = isCrashed
    }
}

func parseTrack(from grid: [[Character]]) -> [[Track?]] {
    // Assuming all rows of the grid have the same count.
    assert(grid.map { $0.count }.min() == grid.map { $0.count }.max())
    let (width, height) = (grid.first?.count ?? 0, grid.count)

    let horizontalTracks = Set<Character?>(["-", "+", "<", ">"])
    let verticalTracks = Set<Character?>(["|", "+", "^", "v"])

    return grid.enumerated().map { (y, row) in
        row.enumerated().map { (x, character) in
            let right = x < width - 1 ? grid[y][x + 1] : nil
            let left = x > 0 ? grid[y][x - 1] : nil
            let down = y < height - 1 ? grid[y + 1][x] : nil
            let up = y > 0 ? grid[y - 1][x] : nil

            switch character {
            case "+":
                return .intersection
            case "|", "^", "v":
                return .straightVertical
            case "-", ">", "<":
                return .straightHorizontal
            case "\\":
                if verticalTracks.contains(up), horizontalTracks.contains(right) {
                    return .curveUpRight
                } else if verticalTracks.contains(down), horizontalTracks.contains(left) {
                    return .curveDownLeft
                } else {
                    assert(false, "Invalid `\\` track at \(x),\(y)")
                }
            case "/":
                if verticalTracks.contains(up), horizontalTracks.contains(left) {
                    return .curveUpLeft
                } else if verticalTracks.contains(down), horizontalTracks.contains(right) {
                    return .curveDownRight
                } else {
                    assert(false, "Invalid `/` track at \(x),\(y)")
                }
            default:
                return nil
            }
        }
    }
}

func parseCarts(from grid: [[Character]]) -> [Cart] {
    return grid.enumerated().flatMap { (y, row) in
        row.enumerated().compactMap { (x, character) in
            let pos = Position(x: x, y: y)
            switch character {
            case "^":
                return Cart(position: pos, direction: .up)
            case "v":
                return Cart(position: pos, direction: .down)
            case "<":
                return Cart(position: pos, direction: .left)
            case ">":
                return Cart(position: pos, direction: .right)
            default:
                return nil
            }
        }
    }
}

func format(track: [[Track?]], carts: [Cart]) -> String {
    func format(cart: Cart) -> String {
        guard !cart.isCrashed else {
            return "X"
        }
            
        switch cart.direction {
        case .up:
            return "^"
        case .down:
            return "v"
        case .left:
            return "<"
        case .right:
            return ">"
        }
    }
    
    return track.enumerated().map { (y, row) in
        row.enumerated().map { (x, trackItem) in
            if let cart = carts.first(where: { $0.position.x == x && $0.position.y == y }) {
                return format(cart: cart)
            }
            
            guard let trackItem = trackItem else {
                return " "
            }
            switch trackItem {
            case .intersection:
                return "+"
            case .straightVertical:
                return "|"
            case .straightHorizontal:
                return "-"
            case .curveUpRight:
                return "\\"
            case .curveUpLeft:
                return "/"
            case .curveDownRight:
                return "/"
            case .curveDownLeft:
                return "\\"
            }
        }.joined(separator: "")
    }.joined(separator: "\n")
}

func tick(track: [[Track?]], carts: [Cart]) -> [Cart] {
    // Assuming all rows of the track have the same count.
    assert(track.map { $0.count }.min() == track.map { $0.count }.max())
    let (trackWidth, trackHeight) = (track.first?.count ?? 0, track.count)

    var sortedCarts: [Cart] = carts.sorted(by: { $0.position < $1.position })
    for cartIndex in 0..<sortedCarts.count {
        let cart = sortedCarts[cartIndex]

        // Cart is stuck once it has crashed.
        guard !cart.isCrashed else {
            continue
        }

        // Find the next position of the cart based on its current
        // direction.
        let nextPosition: Position
        switch cart.direction {
        case .up:
            nextPosition = Position(x: cart.position.x, y: cart.position.y - 1)
        case .down:
            nextPosition = Position(x: cart.position.x, y: cart.position.y + 1)
        case .left:
            nextPosition = Position(x: cart.position.x - 1, y: cart.position.y)
        case .right:
            nextPosition = Position(x: cart.position.x + 1, y: cart.position.y)
        }

        // The position should always be valid at this point and a
        // track will always exist, otherwise we have invalid track.
        guard
          nextPosition.x >= 0,
          nextPosition.x < trackWidth,
          nextPosition.y >= 0,
          nextPosition.y < trackHeight,
          let nextTrack = track[nextPosition.y][nextPosition.x]
        else {
            assert(false, "Cart is going to derail at \(nextPosition): \(cart)")
        }

        // Find the new direction the cart should face based on the
        // track it just moved to.
        let nextDirection: CartDirection
        let nextTurnDirection: TurnDirection?
        switch nextTrack {
        case .intersection:
            nextDirection = cart.direction.turned(cart.nextTurnDirection)
            nextTurnDirection = cart.nextTurnDirection.next
        case .straightVertical, .straightHorizontal:
            nextDirection = cart.direction
            nextTurnDirection = nil
        case .curveUpRight:
            switch cart.direction {
            case .down:
                nextDirection = .right
            case .left:
                nextDirection = .up
            case .up, .right:
                fatalError("Impossible cart direction")
            }
            nextTurnDirection = nil
        case .curveUpLeft:
            switch cart.direction {
            case .down:
                nextDirection = .left
            case .right:
                nextDirection = .up
            case .up, .left:
                fatalError("Impossible cart direction")
            }
            nextTurnDirection = nil
        case .curveDownRight:
            switch cart.direction {
            case .up:
                nextDirection = .right
            case .left:
                nextDirection = .down
            case .down, .right:
                fatalError("Impossible cart direction")
            }
            nextTurnDirection = nil
        case .curveDownLeft:
            switch cart.direction {
            case .up:
                nextDirection = .left
            case .right:
                nextDirection = .down
            case .down, .left:
                fatalError("Impossible cart direction")
            }
            nextTurnDirection = nil
        }

        var nextIsCrashed = false
        for (otherCartIndex, otherCart) in sortedCarts.enumerated() {
            guard cartIndex != otherCartIndex else {
                continue
            }

            if nextPosition.x == otherCart.position.x && nextPosition.y == otherCart.position.y {
                nextIsCrashed = true
                sortedCarts[otherCartIndex] = Cart(
                  position: otherCart.position,
                  direction: otherCart.direction,
                  nextTurnDirection: otherCart.nextTurnDirection,
                  isCrashed: true)
            }
        }

        sortedCarts[cartIndex] = Cart(
          position: nextPosition,
          direction: nextDirection,
          nextTurnDirection: nextTurnDirection ?? cart.nextTurnDirection,
          isCrashed: nextIsCrashed)
    }

    return sortedCarts
}

let grid = input.split(separator: "\n").map { line in line.map { $0 } }
let track = parseTrack(from: grid)
let initialCarts = parseCarts(from: grid)

var carts = initialCarts
while true {
    // Clear screen
    // print("\u{001b}[H\u{001b}[2J", terminator: "")

    carts = tick(track: track, carts: carts)

    // print(format(track: track, carts: carts))

    let crashPositions = carts
      .filter { $0.isCrashed }
      .map { $0.position }
      .sorted()
    if let firstCrashPosition = crashPositions.first {
        print("Part 1 crashes at \(firstCrashPosition)")
        break
    }

    // Thread.sleep(forTimeInterval: 0.33)
}

// --- Part Two ---

// There isn't much you can do to prevent crashes in this ridiculous
// system. However, by predicting the crashes, the Elves know where to
// be in advance and instantly remove the two crashing carts the
// moment any crash occurs.

// They can proceed like this for a while, but eventually, they're
// going to run out of carts. It could be useful to figure out where
// the last cart that hasn't crashed will end up.

// For example:

// />-<\  
// |   |  
// | /<+-\
// | | | v
// \>+</ |
//   |   ^
//   \<->/

// /---\  
// |   |  
// | v-+-\
// | | | |
// \-+-/ |
//   |   |
//   ^---^

// /---\  
// |   |  
// | /-+-\
// | v | |
// \-+-/ |
//   ^   ^
//   \---/

// /---\  
// |   |  
// | /-+-\
// | | | |
// \-+-/ ^
//   |   |
//   \---/

// After four very expensive crashes, a tick ends with only one cart
// remaining; its final location is 6,4.

// What is the location of the last cart at the end of the first tick
// where it is the only cart left?

carts = initialCarts
while true {
    carts = tick(track: track, carts: carts)
    carts = carts.filter { !$0.isCrashed }
    if carts.count == 1, let finalCart = carts.last {
        print("Part 2 final cart at \(finalCart.position)")
        break
    }
}
