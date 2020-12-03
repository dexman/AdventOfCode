import Foundation

typealias Opcode = (CPU) -> (OpcodeArgs) -> ()
typealias OpcodeArgs = (a: Int, b: Int, c: Int)

class CPU {
    var registers: [Int] = [0, 0, 0, 0, 0, 0]

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

    func run(_ program: [(String, Opcode, OpcodeArgs)]) -> Int {
        var instructionCount = 0
        var seenR1 = Set<Int>()
        while instructionPointer >= 0, instructionPointer < program.count {
            let shouldLog = instructionPointer == 28
            var log = shouldLog ? "ip=\([instructionPointer) \(registers)": nil
            let nameOpcodeArgs = program[instructionPointer]
            if var log = log {
                log += " \(nameOpcodeArgs.0) \(nameOpcodeArgs.2)"
            }
            nameOpcodeArgs.1(self)(nameOpcodeArgs.2)
            if var log = log {
                log += " \(registers)"
                print(log)
                if seenR1.contains(registers[1]) {
                    print("count=\(instructionCount) seenR1=\(seenR1)")
                    exit(0)
                } else {
                    seenR1.insert(registers[1])
                }
            }
            incrementInstructionPointer()
            instructionCount += 1
        }
        return instructionCount
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
if let ipRegister = ipRegister {
    cpu.instructionPointerRegister = ipRegister
}
cpu.registers[0] = 10332277
_ = cpu.run(program)
print("Part 1 value of registers: \(cpu.registers)")


// Part 1: The program exits when r1 > r0. The first time this test is
// made r1 is 10332277, so set r0 to 10332277. This is the answer to
// part 1.


//
// Part 2
//

cpu = CPU()
if let ipRegister = ipRegister {
    cpu.instructionPointerRegister = ipRegister
}
cpu.registers[0] = 0
let count = cpu.run(program)
print("Part 2 value of registers: \(cpu.registers) count=\(count)")

// Last 5 updates before a repeat (15353295 is the repeat).
//ip=28 [0, 1066170, 75, 1, 1, 28] [0, 1066170, 75, 1, 0, 28]
//ip=28 [0, 9866391, 17, 1, 1, 28] [0, 9866391, 17, 1, 0, 28]
//ip=28 [0, 3403592, 151, 1, 1, 28] [0, 3403592, 151, 1, 0, 28]
//ip=28 [0, 14184810, 51, 1, 1, 28] [0, 14184810, 51, 1, 0, 28]
//ip=28 [0, 13846724, 217, 1, 1, 28] [0, 13846724, 217, 1, 0, 28]
//ip=28 [0, 15353295, 211, 1, 1, 28] [0, 15353295, 211, 1, 0, 28]
