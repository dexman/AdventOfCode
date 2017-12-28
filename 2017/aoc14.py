# --- Day 14: Disk Defragmentation ---

# Suddenly, a scheduled job activates the system's disk defragmenter. Were the
# situation different, you might sit and watch it for a while, but today, you
# just don't have that kind of time. It's soaking up valuable system resources
# that are needed elsewhere, and so the only option is to help it finish its
# task as soon as possible.

# The disk in question consists of a 128x128 grid; each square of the grid is
# either free or used. On this disk, the state of the grid is tracked by the
# bits in a sequence of knot hashes.

# A total of 128 knot hashes are calculated, each corresponding to a single row
# in the grid; each hash contains 128 bits which correspond to individual grid
# squares. Each bit of a hash indicates whether that square is free (0) or used
# (1).

# The hash inputs are a key string (your puzzle input), a dash, and a number
# from 0 to 127 corresponding to the row. For example, if your key string were
# flqrgnkx, then the first row would be given by the bits of the knot hash of
# flqrgnkx-0, the second row from the bits of the knot hash of flqrgnkx-1, and
# so on until the last row, flqrgnkx-127.

# The output of a knot hash is traditionally represented by 32 hexadecimal
# digits; each of these digits correspond to 4 bits, for a total of 4 * 32 =
# 128 bits. To convert to bits, turn each hexadecimal digit to its equivalent
# binary value, high-bit first: 0 becomes 0000, 1 becomes 0001, e becomes 1110,
# f becomes 1111, and so on; a hash that begins with a0c2017... in hexadecimal
# would begin with 10100000110000100000000101110000... in binary.

# Continuing this process, the first 8 rows and columns for key flqrgnkx appear
# as follows, using # to denote used squares, and . to denote free ones:

# ##.#.#..-->
# .#.#.#.#   
# ....#.#.   
# #.#.##.#   
# .##.#...   
# ##..#..#   
# .#...#..   
# ##.#.##.-->
# |      |   
# V      V

# In this example, 8108 squares are used across the entire 128x128 grid.

# Given your actual key string, how many squares are used?

# Your puzzle input is oundnydw.

# --- Part Two ---

# Now, all the defragmenter needs to know is the number of regions. A region is
# a group of used squares that are all adjacent, not including diagonals. Every
# used square is in exactly one region: lone used squares form their own
# isolated regions, while several adjacent squares all count as a single
# region.

# In the example above, the following nine regions are visible, each marked
# with a distinct digit:

# 11.2.3..-->
# .1.2.3.4   
# ....5.6.   
# 7.8.55.9   
# .88.5...   
# 88..5..8   
# .8...8..   
# 88.8.88.-->
# |      |   
# V      V   

# Of particular interest is the region marked 8; while it does not appear
# contiguous in this small view, all of the squares marked 8 are connected when
# considering the whole 128x128 grid. In total, in this example, 1242 regions
# are present.

# How many regions are present given your key string?

################################################################################

def knot_hash(string):
    def hash_lengths(lengths, rounds=64):
        numbers = list(range(256))
        position = 0
        skip = 0
        for _ in range(rounds):
            for length in lengths:
                for i in range(length // 2):
                    lhs_index = (position + i) % len(numbers)
                    rhs_index = (position + length - i - 1) % len(numbers)
                    numbers[lhs_index], numbers[rhs_index] = numbers[rhs_index], numbers[lhs_index]
                position += length + skip
                skip += 1
        return numbers

    def densify(numbers):
        result = []
        for block_index in range(16):
            block_result = 0
            for index in range(16):
                block_result = block_result ^ numbers[block_index * 16 + index]
            result.append(block_result)
        return result

    def hexformat(number):
        return f'{number:02x}'

    lengths = [ord(c) for c in string] + [17, 31, 73, 47, 23]
    numbers = hash_lengths(lengths)
    return ''.join(map(hexformat, densify(numbers)))

def build_disk(key):
    hashes = [knot_hash(f'{key}-{row}') for row in range(128)]
    return [int(hash, base=16) for hash in hashes]

def is_used(x, y, disk):
    if x < 0 or x > 127 or y < 0 or y > 127:
        return False
    row = disk[y]
    bit = row & (2 ** (127 - x))
    return bit != 0

def count_used_squares(disk):
    total_used = 0
    for y in range(128):
        for x in range(128):
            if is_used(x, y, disk):
                total_used += 1
    return total_used

def count_used_regions(disk):
    regions = [[None] * 128 for _ in range(128)]
    def mark_region(x, y, region):
        if not is_used(x, y, disk) or regions[y][x]:
            return
        regions[y][x] = region
        mark_region(x - 1, y, region)
        mark_region(x + 1, y, region)
        mark_region(x, y - 1, region)
        mark_region(x, y + 1, region)
    next_region_id = 1
    for y in range(128):
        for x in range(128):
            if not regions[y][x] and is_used(x, y, disk):
                mark_region(x, y, next_region_id)
                next_region_id += 1
    return next_region_id - 1
                

key = 'oundnydw'
disk = build_disk(key)

total_used = count_used_squares(disk)
print(f'Part 1: There are {total_used} total squares used.')

total_regions = count_used_regions(disk)
print(f'Part 2: There are {total_regions} regions.')
    
