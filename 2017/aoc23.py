# --- Day 23: Coprocessor Conflagration ---

# You decide to head directly to the CPU and fix the printer from there. As you
# get close, you find an experimental coprocessor doing so much work that the
# local programs are afraid it will halt and catch fire. This would cause
# serious issues for the rest of the computer, so you head in and see what you
# can do.

# The code it's running seems to be a variant of the kind you saw recently on
# that tablet. The general functionality seems very similar, but some of the
# instructions are different:

# set X Y sets register X to the value of Y.

# sub X Y decreases register X by the value of Y.

# mul X Y sets register X to the result of multiplying the value contained in
# register X by the value of Y.

# jnz X Y jumps with an offset of the value of Y, but only if the value of X is
# not zero. (An offset of 2 skips the next instruction, an offset of -1 jumps
# to the previous instruction, and so on.)

# Only the instructions listed above are used. The eight registers here, named
# a through h, all start at 0.

# The coprocessor is currently set to some kind of debug mode, which allows for
# testing, but prevents it from doing any meaningful work.

# If you run the program (your puzzle input), how many times is the mul
# instruction invoked?

# --- Part Two ---

# Now, it's time to fix the problem.

# The debug mode switch is wired directly to register a. You flip the switch,
# which makes register a now start at 1 when the program is executed.

# Immediately, the coprocessor begins to overheat. Whoever wrote this program
# obviously didn't choose a very efficient implementation. You'll need to
# optimize the program if it has any hope of completing before Santa needs that
# printer working.

# The coprocessor's ultimate goal is to determine the final value left in
# register h once the program completes. Technically, if it had that... it
# wouldn't even need to run the program.

# After setting register a to 1, if the program were to run to completion, what
# value would be left in register h?

################################################################################

import collections
import math
import re

def set(registers, x, y):
    registers[x] = value(registers, y)

def sub(registers, x, y):
    registers[x] -= value(registers, y)

def mul(registers, x, y):
    registers[x] *= value(registers, y)

def jnz(registers, x, y):
    if value(registers, x) != 0:
        return value(registers, y)

def value(registers, x):
    if x.isalpha():
        return registers[x]
    else:
        return int(x)

def execute(instructions, debug=False):
    registers = collections.defaultdict(lambda: 0)
    counts = collections.defaultdict(lambda: 0)
    pc = 0
    if debug:
        registers['a'] = 1
    while pc >= 0 and pc < len(instructions):
        operation, args = instructions[pc]
        jump = operation(registers, *args)
        if jump is not None:
            pc += jump
        else:
            pc += 1
        if not debug:
            counts[operation] += 1
    return registers, counts

def parse_instructions(instructions_input):
    def parse_line(line):
        line = re.sub(r'#.*', '', line)
        cmd, *args = line.strip().split(' ')
        return (globals()[cmd], args)
    return [parse_line(l) for l in instructions_input.strip().splitlines()]

with open('aoc23.txt', 'r') as f:
    instructions_input = f.read()
instructions = parse_instructions(instructions_input)

registers, counts = execute(instructions)
print(f'Part 1: The mul instruction was executed {counts[mul]} times.')

# Part 2, the given input program is counting the number of values b that have
# any integer factor >= 2. The value b is every 17 numbers in the range
# [108100, 125100]. We can implement this algorithm more directly in Python.
h = 0
for b in range(108100, 125101, 17):
    for d in range(2, int(math.sqrt(b))):
        if b % d == 0:
            h += 1
            break
print(f'Part 2: The value of register h is {h}.')
