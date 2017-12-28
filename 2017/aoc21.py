# --- Day 21: Fractal Art ---

# You find a program trying to generate some art. It uses a strange process
# that involves repeatedly enhancing the detail of an image through a set of
# rules.

# The image consists of a two-dimensional square grid of pixels that are either
# on (#) or off (.). The program always begins with this pattern:

# .#.
# ..#
# ###

# Because the pattern is both 3 pixels wide and 3 pixels tall, it is said to
# have a size of 3.

# Then, the program repeats the following process:

# If the size is evenly divisible by 2, break the pixels up into 2x2 squares,
# and convert each 2x2 square into a 3x3 square by following the corresponding
# enhancement rule.

# Otherwise, the size is evenly divisible by 3; break the pixels up into 3x3
# squares, and convert each 3x3 square into a 4x4 square by following the
# corresponding enhancement rule.

# Because each square of pixels is replaced by a larger one, the image gains
# pixels and so its size increases.

# The artist's book of enhancement rules is nearby (your puzzle input);
# however, it seems to be missing rules. The artist explains that sometimes,
# one must rotate or flip the input pattern to find a match. (Never rotate or
# flip the output pattern, though.) Each pattern is written concisely: rows are
# listed as single units, ordered top-down, and separated by slashes. For
# example, the following rules correspond to the adjacent patterns:

# ../.#  =  ..
#           .#

#                 .#.
# .#./..#/###  =  ..#
#                 ###

#                         #..#
# #..#/..../#..#/.##.  =  ....
#                         #..#
#                         .##.

# When searching for a rule to use, rotate and flip the pattern as
# necessary. For example, all of the following patterns match the same rule:

# .#.   .#.   #..   ###
# ..#   #..   #.#   ..#
# ###   ###   ##.   .#.
# Suppose the book contained the following two rules:

# ../.# => ##./#../...
# .#./..#/### => #..#/..../..../#..#
# As before, the program begins with this pattern:

# .#.
# ..#
# ###

# The size of the grid (3) is not divisible by 2, but it is divisible by 3. It
# divides evenly into a single square; the square matches the second rule,
# which produces:

# #..#
# ....
# ....
# #..#

# The size of this enhanced grid (4) is evenly divisible by 2, so that rule is
# used. It divides evenly into four squares:

# #.|.#
# ..|..
# --+--
# ..|..
# #.|.#

# Each of these squares matches the same rule (../.# => ##./#../...), three of
# which require some flipping and rotation to line up with the rule. The output
# for the rule is the same in all four cases:

# ##.|##.
# #..|#..
# ...|...
# ---+---
# ##.|##.
# #..|#..
# ...|...

# Finally, the squares are joined into a new grid:

# ##.##.
# #..#..
# ......
# ##.##.
# #..#..
# ......

# Thus, after 2 iterations, the grid contains 12 pixels that are on.

# How many pixels stay on after 5 iterations?

# --- Part Two ---

# How many pixels stay on after 18 iterations?

################################################################################

OFF = '.'
ON = '#'

class Image:
    def __init__(self, rows):
        self.size = len(rows)
        self._rows = rows

    def __str__(self):
        result = ''
        for y in range(self.size):
            if len(result) > 0:
                result += '\n'
            for x in range(self.size):
                result += self.get(x, y)
        return result

    def __eq__(self, other):
        if self.size != other.size:
            return False
        for y in range(self.size):
            for x in range(self.size):
                if self.get(x, y) != other.get(x, y):
                    return False
        return True

    def pixels_count(self):
        return f'{self}'.count(ON)

    def get(self, x, y):
        return self._rows[y][x]

    def set(self, x, y, value):
        self._rows[y][x] = value

    def rotated(self, n):
        if n <= 0:
            return self
        n = n % 4
        return RotatedImage(self).rotated(n - 1)

    def horizontally_flipped(self):
        return HorizontallyFlippedImage(self)

    def vertically_flipped(self):
        return VerticallyFlippedImage(self)
    
    def enhanced(self, patterns):
        src_size = self.size
        if src_size % 2 == 0:
            src_block_size = 2
        else:
            src_block_size = 3
        blocks_count = src_size // src_block_size

        dst_block_size = src_block_size + 1
        dst_size = src_size // src_block_size * dst_block_size
        dst_rows = [[OFF] * dst_size for _ in range(dst_size)]

        for block_y in range(blocks_count):
            src_y = block_y * src_block_size
            for block_x in range(blocks_count):
                src_x = block_x * src_block_size
                block = SubImage(self, src_x, src_y, src_block_size)
                output = patterns[f'{block}']
                for pat_y in range(output.size):
                    dst_y = pat_y + block_y * dst_block_size
                    for pat_x in range(output.size):
                        dst_x = pat_x + block_x * dst_block_size
                        dst_rows[dst_y][dst_x] = output.get(pat_x, pat_y)

        return Image(dst_rows)

class SubImage(Image):
    def __init__(self, src_image, src_x, src_y, size):
        self.size = size
        self._src_image = src_image
        self._src_x = src_x
        self._src_y = src_y

    def get(self, x, y):
        self._ensure_coordinate(x, y)
        return self._src_image.get(self._src_x + x, self._src_y + y)

    def set(self, x, y, value):
        self._ensure_coordinate(x, y)
        self._src_image.set(self._src_x + x, self._src_y + y, value)

    def _ensure_coordinate(self, x, y):
        if x < 0 or x >= self.size:
            raise IndexError()
        if y < 0 or y >= self.size:
            raise IndexError()

class RotatedImage(Image):
    def __init__(self, src_image):
        self.size = src_image.size
        self._src_image = src_image

    def get(self, x, y):
        return self._src_image.get(self.size - y - 1, x)

    def set(self, x, y, value):
        self._src_image.set(self.size - y - 1, x, value)

class HorizontallyFlippedImage(Image):
    def __init__(self, src_image):
        self.size = src_image.size
        self._src_image = src_image

    def get(self, x, y):
        return self._src_image.get(self.size - x - 1, y)

    def set(self, x, y, value):
        self._src_image.set(self.size - x - 1, y, value)

class VerticallyFlippedImage(Image):
    def __init__(self, src_image):
        self.size = src_image.size
        self._src_image = src_image

    def get(self, x, y):
        return self._src_image.get(x, self.size - y - 1)

    def set(self, x, y, value):
        self._src_image.set(x, self.size - y - 1, value)

def parse_image(image_input_str):
    return Image([line for line in image_input_str.strip().splitlines()])

def parse_pattern(pattern_input_str):
    pattern_input, pattern_output = map(
        lambda s: parse_image(s.replace('/', '\n')),
        pattern_input_str.split(' => '))
    return pattern_input, pattern_output

start_image = parse_image('.#.\n..#\n###')
with open('aoc21.txt', 'r') as f:
    patterns_list = [parse_pattern(l) for l in f.read().strip().splitlines()]
    patterns = {}
    for input_pattern, output_pattern in patterns_list:
        for n in range(4):
            rotated = input_pattern.rotated(n)
            patterns[f'{rotated}'] = output_pattern
            patterns[f'{rotated.horizontally_flipped()}'] = output_pattern
            patterns[f'{rotated.vertically_flipped()}'] = output_pattern

image = start_image
for _ in range(5):
    image = image.enhanced(patterns)
print(f'Part 1: There are {image.pixels_count()} pixels on.')

image = start_image
for n in range(18):
    image = image.enhanced(patterns)
print(f'Part 2: There are {image.pixels_count()} pixels on.')
