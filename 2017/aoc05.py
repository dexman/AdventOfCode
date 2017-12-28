# --- Day 5: A Maze of Twisty Trampolines, All Alike ---

# An urgent interrupt arrives from the CPU: it's trapped in a maze of jump
# instructions, and it would like assistance from any programs with spare
# cycles to help find the exit.

# The message includes a list of the offsets for each jump. Jumps are relative:
# -1 moves to the previous instruction, and 2 skips the next one. Start at the
# first instruction in the list. The goal is to follow the jumps until one
# leads outside the list.

# In addition, these instructions are a little strange; after each jump, the
# offset of that instruction increases by 1. So, if you come across an offset
# of 3, you would move three instructions forward, but change it to a 4 for the
# next time it is encountered.

# For example, consider the following list of jump offsets:

# 0
# 3
# 0
# 1
# -3

# Positive jumps ("forward") move downward; negative jumps move upward. For
# legibility in this example, these offset values will be written all on one
# line, with the current instruction marked in parentheses. The following steps
# would be taken before an exit is found:

# (0) 3  0  1  -3  - before we have taken any steps.

# (1) 3 0 1 -3 - jump with offset 0 (that is, don't jump at all). Fortunately,
# the instruction is then incremented to 1.

#  2 (3) 0 1 -3 - step forward because of the instruction we just modified. The
#  first instruction is incremented again, now to 2.

#  2  4  0  1 (-3) - jump all the way to the end; leave a 4 behind.

#  2 (4) 0  1  -2  - go back to where we just were; increment -3 to -2.

#  2  5  0  1  -2  - jump 4 steps forward, escaping the maze.

# In this example, the exit is reached in 5 steps.

# How many steps does it take to reach the exit?

# --- Part Two ---

# Now, the jumps are even stranger: after each jump, if the offset was three or
# more, instead decrease it by 1. Otherwise, increase it by 1 as before.

# Using this rule with the above example, the process now takes 10 steps, and
# the offset values after finding the exit are left as 2 3 2 3 -1.

# How many steps does it now take to reach the exit?

################################################################################

def follow(modify_offset, offsets):
    steps_count = 0
    offset_index = 0
    while offset_index < len(offsets):
        offset = offsets[offset_index]
        new_offset_index = offset_index + offset

        offsets[offset_index] = modify_offset(offset)
        offset_index = new_offset_index

        steps_count += 1
    return steps_count

def follow_part1(offsets):
    def modify_offset(offset):
        return offset + 1
    return follow(modify_offset, offsets)

def follow_part2(offsets):
    def modify_offset(offset):
        if offset >= 3:
            return offset - 1
        else:
            return offset + 1
    return follow(modify_offset, offsets)

def parse_offsets(offsets_string):
    lines = offsets_string.strip().split('\n')
    return list(map(int, lines))

with open('aoc05.txt', 'r') as f:
    offsets = parse_offsets(f.read())
    steps_count = follow_part1(offsets)
    print(f'Part 1: Took {steps_count} steps to exit.')

with open('aoc05.txt', 'r') as f:
    offsets = parse_offsets(f.read())
    steps_count = follow_part2(offsets)
    print(f'Part 2: Took {steps_count} steps to exit.')
