// --- Day 8: Memory Maneuver ---

// The sleigh is much easier to pull than you'd expect for something
// its weight. Unfortunately, neither you nor the Elves know which way
// the North Pole is from here.

// You check your wrist device for anything that might help. It seems
// to have some kind of navigation system! Activating the navigation
// system produces more bad news: "Failed to start navigation
// system. Could not read software license file."

// The navigation system's license file consists of a list of numbers
// (your puzzle input). The numbers define a data structure which,
// when processed, produces some kind of tree that can be used to
// calculate the license number.

// The tree is made up of nodes; a single, outermost node forms the
// tree's root, and it contains all other nodes in the tree (or
// contains nodes that contain nodes, and so on).

// Specifically, a node consists of:

// A header, which is always exactly two numbers:
// The quantity of child nodes.
// The quantity of metadata entries.
// Zero or more child nodes (as specified in the header).
// One or more metadata entries (as specified in the header).

// Each child node is itself a node that has its own header, child
// nodes, and metadata. For example:

// 2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2
// A----------------------------------
//     B----------- C-----------
//                      D-----

// In this example, each node of the tree is also marked with an
// underline starting with a letter for easier identification. In it,
// there are four nodes:

// A, which has 2 child nodes (B, C) and 3 metadata entries (1, 1, 2).
// B, which has 0 child nodes and 3 metadata entries (10, 11, 12).
// C, which has 1 child node (D) and 1 metadata entry (2).
// D, which has 0 child nodes and 1 metadata entry (99).

// The first check done on the license file is to simply add up all of
// the metadata entries. In this example, that sum is
// 1+1+2+10+11+12+2+99=138.

// What is the sum of all metadata entries?

import Foundation

let inputFilePath = CommandLine.arguments[1]
let input = try! String(contentsOfFile: inputFilePath, encoding: .utf8)

struct Node {
    let children: [Node]
    let metadata: [Int]
}

func parse(_ numbers: [Int]) -> Node {
    func doparsechildren(numbers: [Int], children: [Node], childrenCount: Int) -> ([Node], [Int]) {
        if childrenCount <= 0 {
            return (children, numbers)
        } else {
            let (child, remaining) = doparse(numbers)
            return doparsechildren(
              numbers: remaining,
              children: children + [child],
              childrenCount: childrenCount - 1)
        }
    }

    func doparse(_ numbers: [Int]) -> (Node, [Int]) {
        assert(numbers.count > 1)
        
        let childrenCount = numbers[0]
        let metadataCount = numbers[1]
        let numbersAfterHeader = Array(numbers.dropFirst(2))

        let (children, numbersAfterChildren) = doparsechildren(
          numbers: numbersAfterHeader,
          children: [],
          childrenCount: childrenCount)

        let metadata = Array(numbersAfterChildren.prefix(metadataCount))
        let numbersAfterMetadata = Array(numbersAfterChildren.dropFirst(metadataCount))

        let node = Node(children: children, metadata: metadata)
        
        return (node, numbersAfterMetadata)
    }
    return doparse(numbers).0
}

func walkPrefix(_ root: Node, block: (Node) -> ()) {
    block(root)
    for child in root.children {
        walkPrefix(child, block: block)
    }
}

let numbers = input
  .trimmingCharacters(in: .whitespacesAndNewlines)
  .split(separator: " ")
  .map { Int($0)! }
let tree = parse(numbers)

var metadataSum = 0
walkPrefix(tree) { node in
    metadataSum += node.metadata.reduce(0, +)
}

print("Part 1 sum of metadata entries: \(metadataSum).")

// --- Part Two ---

// The second check is slightly more complicated: you need to find the
// value of the root node (A in the example above).

// The value of a node depends on whether it has child nodes.

// If a node has no child nodes, its value is the sum of its metadata
// entries. So, the value of node B is 10+11+12=33, and the value of
// node D is 99.

// However, if a node does have child nodes, the metadata entries
// become indexes which refer to those child nodes. A metadata entry
// of 1 refers to the first child node, 2 to the second, 3 to the
// third, and so on. The value of this node is the sum of the values
// of the child nodes referenced by the metadata entries. If a
// referenced child node does not exist, that reference is skipped. A
// child node can be referenced multiple time and counts each time it
// is referenced. A metadata entry of 0 does not refer to any child
// node.

// For example, again using the above nodes:

// Node C has one metadata entry, 2. Because node C has only one child
// node, 2 references a child node which does not exist, and so the
// value of node C is 0.

// Node A has three metadata entries: 1, 1, and 2. The 1 references
// node A's first child node, B, and the 2 references node A's second
// child node, C. Because node B has a value of 33 and node C has a
// value of 0, the value of node A is 33+33+0=66.

// So, in this example, the value of the root node is 66.

// What is the value of the root node?

func treeValue(_ root: Node) -> Int {
    if root.children.isEmpty {
        return root.metadata.reduce(0, +)
    } else {
        let childIndices = root.metadata
          .map { $0 - 1 }
          .filter { $0 >= 0 && $0 < root.children.count }
        return childIndices.reduce(0) { result, childIndex in
            result + treeValue(root.children[childIndex])
        }
    }
}

let value = treeValue(tree)
print("Part 2 tree value: \(value).")
