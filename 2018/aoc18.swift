import Foundation

enum Acre: Character {
    case openGround = "."
    case trees = "|"
    case lumberyard = "#"
}

func parseAcres(from input: String) -> [[Acre]] {
    return input
      .split(separator: "\n")
      .map { line in
          line.map { character in
              Acre(rawValue: character)!
          }
      }
}

func format(_ acres: [[Acre]]) -> String {
    return acres.map {
        String($0.map { $0.rawValue })
    }.joined(separator: "\n")
}

func countAdjacent(cy: Int, cx: Int, in acres: [[Acre]], type: Acre) -> Int {
    var result = 0
    for y in (cy - 1)...(cy + 1) {
        guard
          y >= 0,
          y < acres.count
        else {
            continue
        }
        for x in (cx - 1)...(cx + 1) {
            guard
              x >= 0,
              x < acres[y].count,
              x != cx || y != cy
            else {
                continue
            }
            if acres[y][x] == type {
                result += 1
            }
        }
    }
    return result
}

func magicStep(_ acres: [[Acre]]) -> [[Acre]] {
    var newAcres = acres
    for y in 0..<acres.count {
        for x in 0..<acres[y].count {
            switch acres[y][x] {
            case .openGround:
                if countAdjacent(cy: y, cx: x, in: acres, type: .trees) > 2 {
                    newAcres[y][x] = .trees
                }
            case .trees:
                if countAdjacent(cy: y, cx: x, in: acres, type: .lumberyard) > 2 {
                    newAcres[y][x] = .lumberyard
                }
            case .lumberyard:
                let lumberyards = countAdjacent(cy: y, cx: x, in: acres, type: .lumberyard)
                let trees = countAdjacent(cy: y, cx: x, in: acres, type: .trees)
                if lumberyards == 0 || trees == 0 {
                    newAcres[y][x] = .openGround
                }
            }
        }
    }
    return newAcres
}

func resourceValue(of acres: [[Acre]]) -> Int {
    let woods = acres.map { row in row.filter { $0 == .trees }.count }.reduce(0, +)
    let lumberyards = acres.map { row in row.filter { $0 == .lumberyard }.count }.reduce(0, +)
    return woods * lumberyards
}

let inputFilePath = CommandLine.arguments[1]
let input = try! String(contentsOfFile: inputFilePath, encoding: .utf8)

var acres = parseAcres(from: input)
for _ in 1...10 {
    acres = magicStep(acres)
}
print("Part 1 resource value: \(resourceValue(of: acres))")

acres = parseAcres(from: input)
var seen: [[[Acre]]: Int] = [acres: 0]
var cycleStart: Int?
var cycleLength = 0
for i in 1...1_000_000_000 {
    acres = magicStep(acres)
    if let original = seen[acres] {
        cycleStart = original
        cycleLength = i - original
        break
    } else {
        seen[acres] = i
    }
}

let endSecond = cycleStart! + (1_000_000_000 - cycleStart!) % cycleLength
acres = parseAcres(from: input)
for _ in 1...endSecond {
    acres = magicStep(acres)
}
print("Part 2 resource value: \(resourceValue(of: acres))")
