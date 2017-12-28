# --- Day 8: I Heard You Like Registers ---

# You receive a signal directly from the CPU. Because of your recent assistance
# with jump instructions, it would like you to compute the result of a series
# of unusual register instructions.

# Each instruction consists of several parts: the register to modify, whether
# to increase or decrease that register's value, the amount by which to
# increase or decrease it, and a condition. If the condition fails, skip the
# instruction without modifying the register. The registers all start at 0. The
# instructions look like this:

# b inc 5 if a > 1
# a inc 1 if b < 5
# c dec -10 if a >= 1
# c inc -20 if c == 10

# These instructions would be processed as follows:

# Because a starts at 0, it is not greater than 1, and so b is not modified.

# a is increased by 1 (to 1) because b is less than 5 (it is 0).

# c is decreased by -10 (to 10) because a is now greater than or equal to 1 (it
# is 1).

# c is increased by -20 (to -10) because c is equal to 10.

# After this process, the largest value in any register is 1.

# You might also encounter <= (less than or equal to) or != (not equal
# to). However, the CPU doesn't have the bandwidth to tell you what all the
# registers are named, and leaves that to you to determine.

# What is the largest value in any register after completing the instructions
# in your puzzle input?

# --- Part Two ---

# To be safe, the CPU also needs to know the highest value held in any register
# during this process so that it can decide how much memory to allocate to
# these operations. For example, in the above instructions, the highest value
# ever held was 10 (in register c after the third instruction was evaluated).

################################################################################

from collections import defaultdict, namedtuple
import re

Instruction = namedtuple('Instruction', [
    'register',
    'operation',
    'argument',
    'test_register',
    'test',
    'test_argument',
])

TESTS = {
    '>': lambda x,y: x > y,
    '<': lambda x,y: x < y,
    '>=': lambda x,y: x >= y,
    '<=': lambda x,y: x <= y,
    '==': lambda x,y: x == y,
    '!=': lambda x,y: x != y,
}

def test(instruction, registers):
    '''Return true if instruction's test is true, otherwise return false.'''
    test = instruction.test
    test_register_value = registers[instruction.test_register]
    test_argument = instruction.test_argument
    return TESTS[test](test_register_value, test_argument)

def operate(instruction, registers):
    '''Perform the operation indicated by the instruction.'''
    register = instruction.register
    operation = instruction.operation
    argument = instruction.argument
    if operation == 'inc':
        registers[register] += argument
    elif operation == 'dec':
        registers[register] -= argument
    else:
        assert False, f'Unknown operation: {operation}'
    
def execute(instructions, registers):
    '''Execute the operations. Return a list of the max value after each
    operation.'''
    max_values = []
    for instruction in instructions:
        if test(instruction, registers):
            operate(instruction, registers)
        max_values.append(max_value(registers))
    return max_values

def max_value(registers):
    return max(registers.values())

def parse_instructions(instructions):
    def parse_instruction(line):
        tokens = re.split(r'\s+', line)
        return Instruction(
            register=tokens[0],
            operation=tokens[1],
            argument=int(tokens[2]),
            test_register=tokens[4],
            test=tokens[5],
            test_argument=int(tokens[6])
        )
    return map(parse_instruction, instructions.splitlines())

def main():
    with open('aoc08.txt', 'r') as f:
        source_code = f.read()
    instructions = parse_instructions(source_code)
    registers = defaultdict(lambda: 0)
    max_values = execute(instructions, registers)

    print(f'Part 1: The largest value at the end is {max_values[-1]}')
    print(f'Part 2: The largest ever is {max(max_values)}')

main()
