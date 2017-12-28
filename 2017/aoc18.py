# --- Day 18: Duet ---

# You discover a tablet containing some strange assembly code labeled simply
# "Duet". Rather than bother the sound card with it, you decide to run the code
# yourself. Unfortunately, you don't see any documentation, so you're left to
# figure out what the instructions mean on your own.

# It seems like the assembly is meant to operate on a set of registers that are
# each named with a single letter and that can each hold a single integer. You
# suppose each register should start with a value of 0.

# There aren't that many instructions, so it shouldn't be hard to figure out
# what they do. Here's what you determine:

# snd X plays a sound with a frequency equal to the value of X.

# set X Y sets register X to the value of Y.

# add X Y increases register X by the value of Y.

# mul X Y sets register X to the result of multiplying the value contained in
# register X by the value of Y.

# mod X Y sets register X to the remainder of dividing the value contained in
# register X by the value of Y (that is, it sets X to the result of X modulo
# Y).

# rcv X recovers the frequency of the last sound played, but only when the
# value of X is not zero. (If it is zero, the command does nothing.)

# jgz X Y jumps with an offset of the value of Y, but only if the value of X is
# greater than zero. (An offset of 2 skips the next instruction, an offset of
# -1 jumps to the previous instruction, and so on.)

# Many of the instructions can take either a register (a single letter) or a
# number. The value of a register is the integer it contains; the value of a
# number is that number.

# After each jump instruction, the program continues with the instruction to
# which the jump jumped. After any other instruction, the program continues
# with the next instruction. Continuing (or jumping) off either end of the
# program terminates it.

# For example:

# set a 1
# add a 2
# mul a a
# mod a 5
# snd a
# set a 0
# rcv a
# jgz a -1
# set a 1
# jgz a -2

# The first four instructions set a to 1, add 2 to it, square it, and then set
# it to itself modulo 5, resulting in a value of 4.

# Then, a sound with frequency 4 (the value of a) is played.

# After that, a is set to 0, causing the subsequent rcv and jgz instructions to
# both be skipped (rcv because a is 0, and jgz because a is not greater than
# 0).

# Finally, a is set to 1, causing the next jgz instruction to activate, jumping
# back two instructions to another jump, which jumps again to the rcv, which
# ultimately triggers the recover operation.

# At the time the recover operation is executed, the frequency of the last
# sound played is 4.

# What is the value of the recovered frequency (the value of the most recently
# played sound) the first time a rcv instruction is executed with a non-zero
# value?

# --- Part Two ---

# As you congratulate yourself for a job well done, you notice that the
# documentation has been on the back of the tablet this entire time. While you
# actually got most of the instructions correct, there are a few key
# differences. This assembly code isn't about sound at all - it's meant to be
# run twice at the same time.

# Each running copy of the program has its own set of registers and follows the
# code independently - in fact, the programs don't even necessarily run at the
# same speed. To coordinate, they use the send (snd) and receive (rcv)
# instructions:

# snd X sends the value of X to the other program. These values wait in a queue
# until that program is ready to receive them. Each program has its own message
# queue, so a program can never receive a message it sent.

# rcv X receives the next value and stores it in register X. If no values are
# in the queue, the program waits for a value to be sent to it. Programs do not
# continue to the next instruction until they have received a value. Values are
# received in the order they are sent.

# Each program also has its own program ID (one 0 and the other 1); the
# register p should begin with this value.

# For example:

# snd 1
# snd 2
# snd p
# rcv a
# rcv b
# rcv c
# rcv d

# Both programs begin by sending three values to the other. Program 0 sends 1,
# 2, 0; program 1 sends 1, 2, 1. Then, each program receives a value (both 1)
# and stores it in a, receives another value (both 2) and stores it in b, and
# then each receives the program ID of the other program (program 0 receives 1;
# program 1 receives 0) and stores it in c. Each program now sees a different
# value in its own copy of register c.

# Finally, both programs try to rcv a fourth time, but no data is waiting for
# either of them, and they reach a deadlock. When this happens, both programs
# terminate.

# It should be noted that it would be equally valid for the programs to run at
# different speeds; for example, program 0 might have sent all three values and
# then stopped at the first rcv before program 1 executed even its first
# instruction.

# Once both of your programs have terminated (regardless of what caused them to
# do so), how many times did program 1 send a value?

################################################################################

import asyncio
import collections

def run(registers, instructions):
    def snd(x):
        registers['snd'] = arg_value(x)
    def set(x, y):
        registers[x] = arg_value(y)
    def add(x, y):
        registers[x] += arg_value(y)
    def mul(x, y):
        registers[x] *= arg_value(y)
    def mod(x, y):
        registers[x] %= arg_value(y)
    def rcv(x):
        if arg_value(x) != 0:
            registers['rcv'] = registers['snd']
    def jgz(x, y):
        if arg_value(x) > 0:
            return arg_value(y)
        else:
            return None
    def arg_value(x):
        if len(x) == 1 and x.isalpha():
            return registers[x]
        else:
            return int(x)

    pc = 0
    while pc < len(instructions):
        cmd, args = instructions[pc]
        operation = locals()[cmd]
        jump = operation(*args)
        if jump is not None:
            pc += jump
        else:
            pc += 1
        if registers['rcv'] != 0:
            break

class Deadlock(Exception): pass
        
class DuetCPU:
    def __init__(self, program_id):
        self.program_id = program_id
        self.registers = collections.defaultdict(lambda: 0)
        self.registers['p'] = program_id
        self.rcv_queue = asyncio.Queue()
        self.rcv_waiting = False
        self.snd_count = 0

    @property
    def is_blocking(self):
        return self.rcv_waiting and self.rcv_queue.empty()

    async def run(self, instructions, other_program):
        async def snd(x):
            self.snd_count += 1
            other_program.rcv_queue.put_nowait(arg_value(x))
        async def set(x, y):
            self.registers[x] = arg_value(y)
        async def add(x, y):
            self.registers[x] += arg_value(y)
        async def mul(x, y):
            self.registers[x] *= arg_value(y)
        async def mod(x, y):
            self.registers[x] %= arg_value(y)
        async def rcv(x):
            self.rcv_waiting = True
            if other_program.is_blocking and self.is_blocking:
                other_program.rcv_queue.put_nowait(None)
                raise Deadlock()
            value = await self.rcv_queue.get()
            if value is None:
                raise Deadlock()
            self.registers[x] = value
            self.rcv_waiting = False
        async def jgz(x, y):
            return arg_value(y) if arg_value(x) > 0 else None
        def arg_value(x):
            return self.registers[x] if x.isalpha() else int(x)

        pc = 0
        while pc >= 0 and pc < len(instructions):
            cmd, args = instructions[pc]
            operation = locals()[cmd]
            try:
                jump = await operation(*args)
            except Deadlock:
                break
            if jump is not None:
                pc += jump
            else:
                pc += 1
        other_program.rcv_queue.put_nowait(None)

def parse_instructions(instructions_input):
    def parse_line(line):
        cmd, *args = line.split(' ')
        return (cmd, args)
    return [parse_line(l) for l in instructions_input.strip().splitlines()]

with open('aoc18.txt', 'r') as f:
    instructions_input = f.read()
instructions = parse_instructions(instructions_input)
registers = collections.defaultdict(lambda: 0)
run(registers, instructions)
print(f'Part 1: Recovered frequency value {registers["rcv"]}')


cpu0 = DuetCPU(0)
cpu1 = DuetCPU(1)
asyncio.get_event_loop().run_until_complete(asyncio.gather(
    cpu0.run(instructions, cpu1),
    cpu1.run(instructions, cpu0)
))
print(f'Part 2: Program 0/1 sent {cpu0.snd_count}/{cpu1.snd_count} values.')
