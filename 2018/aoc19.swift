import Foundation

typealias Opcode = (CPU) -> (OpcodeArgs) -> ()
typealias OpcodeArgs = (a: Int, b: Int, c: Int)

class CPU {
    var registers: [Int] = [0, 0, 0, 0, 0, 0] {
        didSet {
            assert(registers.count == 6)
            if oldValue[0] != registers[0] {
                print("r0=\(registers[0])")
            }
        }
    }

    var instructionPointerRegister: Int = -1

    private var _instructionPointer: Int = 0

    private var instructionPointer: Int {
        if instructionPointerRegister >= 0, instructionPointerRegister < registers.count {
            return registers[instructionPointerRegister]
        } else {
            return _instructionPointer
        }
    }

    private func incrementInstructionPointer() {
        if instructionPointerRegister >= 0, instructionPointerRegister < registers.count {
            registers[instructionPointerRegister] += 1
        } else {
            _instructionPointer += 1
        }
    }

    func run(_ program: [(String, Opcode, OpcodeArgs)]) {
        var sholdLog = false
        while instructionPointer >= 0, instructionPointer < program.count {
            var log = "ip=\([instructionPointer) \(registers)"
            let (opcodeName, opcode, args) = program[instructionPointer]
            log += " \(opcodeName) \(args)"
            opcode(self)(args)
            log += " \(registers)"
            print(log)
            incrementInstructionPointer()
        }
    }

    func addr(_ args: OpcodeArgs) {
        registers[args.c] = registers[args.a] + registers[args.b]
    }

    func addi(_ args: OpcodeArgs) {
        registers[args.c] = registers[args.a] + args.b
    }

    func mulr(_ args: OpcodeArgs) {
        registers[args.c] = registers[args.a] * registers[args.b]
    }

    func muli(_ args: OpcodeArgs) {
        registers[args.c] = registers[args.a] * args.b
    }

    func banr(_ args: OpcodeArgs) {
        registers[args.c] = registers[args.a] & registers[args.b]
    }

    func bani(_ args: OpcodeArgs) {
        registers[args.c] = registers[args.a] & args.b
    }

    func borr(_ args: OpcodeArgs) {
        registers[args.c] = registers[args.a] | registers[args.b]
    }

    func bori(_ args: OpcodeArgs) {
        registers[args.c] = registers[args.a] | args.b
    }

    func setr(_ args: OpcodeArgs) {
        registers[args.c] = registers[args.a]
    }

    func seti(_ args: OpcodeArgs) {
        registers[args.c] = args.a
    }

    func gtir(_ args: OpcodeArgs) {
        registers[args.c] = args.a > registers[args.b] ? 1 : 0
    }

    func gtri(_ args: OpcodeArgs) {
        registers[args.c] = registers[args.a] > args.b ? 1 : 0
    }

    func gtrr(_ args: OpcodeArgs) {
        registers[args.c] = registers[args.a] > registers[args.b] ? 1 : 0
    }

    func eqir(_ args: OpcodeArgs) {
        registers[args.c] = args.a == registers[args.b] ? 1 : 0
    }

    func eqri(_ args: OpcodeArgs) {
        registers[args.c] = registers[args.a] == args.b ? 1 : 0
    }

    func eqrr(_ args: OpcodeArgs) {
        registers[args.c] = registers[args.a] == registers[args.b] ? 1 : 0
    }
}

    func parseProgram(from input: String) -> (Int?, [(String, Opcode, OpcodeArgs)]) {
    let opcodes: [String.SubSequence: Opcode] = [
      "addr": CPU.addr,
      "addi": CPU.addi,
      "mulr": CPU.mulr,
      "muli": CPU.muli,
      "banr": CPU.banr,
      "bani": CPU.bani,
      "borr": CPU.borr,
      "bori": CPU.bori,
      "setr": CPU.setr,
      "seti": CPU.seti,
      "gtir": CPU.gtir,
      "gtri": CPU.gtri,
      "gtrr": CPU.gtrr,
      "eqir": CPU.eqir,
      "eqri": CPU.eqri,
      "eqrr": CPU.eqrr,
    ]

    var ipRegister: Int?
    let program: [(String, Opcode, OpcodeArgs)] = input
      .split(separator: "\n")
      .compactMap { line in
          if line.starts(with: "#ip") {
              ipRegister = line
                .split(separator: " ")
                .dropFirst()
                .compactMap { Int($0) }
                .first
              return nil
          } else {
              let tokens = line.split(separator: " ")
              let opcodeName = tokens[0]
              let argValues = tokens.dropFirst().compactMap { Int($0) }
              let opcode = opcodes[opcodeName]!
              let args = (
                a: argValues[0],
                b: argValues[1],
                c: argValues[2]
              )
              return (String(opcodeName), opcode, args)
          }
      }
    return (ipRegister, program)
}

let inputFilePath = CommandLine.arguments[1]
let input = try! String(contentsOfFile: inputFilePath, encoding: .utf8)

let (ipRegister, program) = parseProgram(from: input)
var cpu = CPU()
// if let ipRegister = ipRegister {
//     cpu.instructionPointerRegister = ipRegister
// }
// cpu.run(program)
// print("Part 1 value of register 0: \(cpu.registers[0])")

cpu = CPU()
if let ipRegister = ipRegister {
    cpu.instructionPointerRegister = ipRegister
}
cpu.registers[0] = 1
cpu.run(program)
print("Part 2 value of register 0: \(cpu.registers[0])")

// TODO: Arthur ...
// r2 gets some initial value at start, depending on r0
//   r0 == 0 => r2 = 905
//   r0 == 1 => r2 = 10551305
// Once r2 is set, the program computes all factors of r2, starting from 1, e.g.
//   1, 5, 187, 905
// Then it sums them
//   r0 = 1 + 5 + 187 + 905 => 1092
// In the r0 = 1 case, the final value of r0 is
//   (1 + 5 + 17 + 85 + 124133 + 620665 + 2110261 + 10551305) => 13406472
