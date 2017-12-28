# --- Day 8: Two-Factor Authentication ---

# You come across a door implementing what you can only assume is an
# implementation of two-factor authentication after a long game of requirements
# telephone.

# To get past the door, you first swipe a keycard (no problem; there was one on
# a nearby desk). Then, it displays a code on a little screen, and you type
# that code on a keypad. Then, presumably, the door unlocks.

# Unfortunately, the screen has been smashed. After a few minutes, you've taken
# everything apart and figured out how it works. Now you just have to work out
# what the screen would have displayed.

# The magnetic strip on the card you swiped encodes a series of instructions
# for the screen; these instructions are your puzzle input. The screen is 50
# pixels wide and 6 pixels tall, all of which start off, and is capable of
# three somewhat peculiar operations:

# rect AxB turns on all of the pixels in a rectangle at the top-left of the
# screen which is A wide and B tall.

# rotate row y=A by B shifts all of the pixels in row A (0 is the top row)
# right by B pixels. Pixels that would fall off the right end appear at the
# left end of the row.

# rotate column x=A by B shifts all of the pixels in column A (0 is the left
# column) down by B pixels. Pixels that would fall off the bottom appear at the
# top of the column.

# For example, here is a simple sequence on a smaller screen:

# rect 3x2 creates a small rectangle in the top-left corner:

# ###....
# ###....
# .......
# rotate column x=1 by 1 rotates the second column down by one pixel:

# #.#....
# ###....
# .#.....
# rotate row y=0 by 4 rotates the top row right by four pixels:

# ....#.#
# ###....
# .#.....
# rotate column x=1 by 1 again rotates the second column down by one pixel,
# causing the bottom pixel to wrap back to the top:

# .#..#.#
# #.#....
# .#.....
# As you can see, this display technology is extremely powerful, and will soon
# dominate the tiny-code-displaying-screen market. That's what the
# advertisement on the back of the display tries to convince you, anyway.

# There seems to be an intermediate check of the voltage used by the display:
# after you swipe your card, if the screen did work, how many pixels should be
# lit?

# --- Part Two ---

# You notice that the screen is only capable of displaying capital letters; in
# the font it uses, each letter is 5 pixels wide and 6 tall.

# After you swipe your card, what code is the screen trying to display?

################################################################################

PIXEL_ON = '\u2588'
PIXEL_OFF = ' '

def rotate(seq, offset):
    return seq[-offset:] + seq[:-offset]

def rect_op(screen, width, height):
    for y in range(height):
        for x in range(width):
            screen[y][x] = PIXEL_ON

def rotate_row_op(screen, row_index, offset):
    screen[row_index] = rotate(screen[row_index], offset)

def rotate_column_op(screen, column_index, offset):
    column = list(map(lambda row: row[column_index], screen))
    rotated_column = rotate(column, offset)
    for row_index, row in enumerate(screen):
        screen[row_index][column_index] = rotated_column[row_index]

OPS = {
    'rect': rect_op,
    'rotate_column': rotate_column_op,
    'rotate_row': rotate_row_op
}

def execute(screen, op):
    name, arg1, arg2 = op
    OPS[name](screen, arg1, arg2)

def print_screen(screen):
    print('\n'.join(map(lambda row: ''.join(row), screen)))
    print('')

def count_lit_pixels(screen):
    return sum(map(lambda row: row.count(PIXEL_ON), screen))
    
def parse_ops(input):
    lines = input.strip().split('\n')
    ops = []
    for line in lines:
        tokens = line.split(' ')
        if tokens[0] == 'rect':
            width, height = map(int, tokens[1].split('x'))
            ops.append(('rect', width, height))
        elif tokens[:2] == ['rotate', 'column']:
            column_index = int(tokens[2].split('=')[1])
            offset = int(tokens[4])
            ops.append(('rotate_column', column_index, offset))
        elif tokens[:2] == ['rotate', 'row']:
            row_index = int(tokens[2].split('=')[1])
            offset = int(tokens[4])
            ops.append(('rotate_row', row_index, offset))
    return ops

with open('aoc08.txt', 'r') as f:
    screen_width = 50
    screen_height = 6
    screen = list(map(lambda _: [PIXEL_OFF] * screen_width, range(screen_height)))
    for op in parse_ops(f.read()):
        execute(screen, op)
    print_screen(screen)

    print(f'There are {count_lit_pixels(screen)} pixels lit.')

    
