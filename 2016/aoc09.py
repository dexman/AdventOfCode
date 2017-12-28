# --- Day 9: Explosives in Cyberspace ---

# Wandering around a secure area, you come across a datalink port to a new part
# of the network. After briefly scanning it for interesting files, you find one
# file in particular that catches your attention. It's compressed with an
# experimental format, but fortunately, the documentation for the format is
# nearby.

# The format compresses a sequence of characters. Whitespace is ignored. To
# indicate that some sequence should be repeated, a marker is added to the
# file, like (10x2). To decompress this marker, take the subsequent 10
# characters and repeat them 2 times. Then, continue reading the file after the
# repeated data. The marker itself is not included in the decompressed output.

# If parentheses or other characters appear within the data referenced by a
# marker, that's okay - treat it like normal data, not a marker, and then
# resume looking for markers after the decompressed section.

# For example:

# ADVENT contains no markers and decompresses to itself with no changes,
# resulting in a decompressed length of 6.

# A(1x5)BC repeats only the B a total of 5 times, becoming ABBBBBC for a
# decompressed length of 7.

# (3x3)XYZ becomes XYZXYZXYZ for a decompressed length of 9.

# A(2x2)BCD(2x2)EFG doubles the BC and EF, becoming ABCBCDEFEFG for a
# decompressed length of 11.

# (6x1)(1x3)A simply becomes (1x3)A - the (1x3) looks like a marker, but
# because it's within a data section of another marker, it is not treated any
# differently from the A that comes after it. It has a decompressed length of
# 6.

# X(8x2)(3x3)ABCY becomes X(3x3)ABC(3x3)ABCY (for a decompressed length of 18),
# because the decompressed data from the (8x2) marker (the (3x3)ABC) is skipped
# and not processed further.

# What is the decompressed length of the file (your puzzle input)? Don't count
# whitespace.

# --- Part Two ---

# Apparently, the file actually uses version two of the format.

# In version two, the only difference is that markers within decompressed data
# are decompressed. This, the documentation explains, provides much more
# substantial compression capabilities, allowing many-gigabyte files to be
# stored in only a few kilobytes.

# For example:

# (3x3)XYZ still becomes XYZXYZXYZ, as the decompressed section contains no
# markers.

# X(8x2)(3x3)ABCY becomes XABCABCABCABCABCABCY, because the decompressed data
# from the (8x2) marker is then further decompressed, thus triggering the (3x3)
# marker twice for a total of six ABC sequences.

# (27x12)(20x12)(13x14)(7x10)(1x12)A decompresses into a string of A repeated
# 241920 times.

# (25x3)(3x3)ABC(2x3)XY(5x2)PQRSTX(18x9)(3x2)TWO(5x7)SEVEN becomes 445
# characters long.

# Unfortunately, the computer you brought probably doesn't have enough memory
# to actually decompress the file; you'll have to come up with another way to
# get its decompressed length.

# What is the decompressed length of the file using this improved format?

################################################################################

import enum

class DecompressState(enum.Enum):
    normal = 0
    marker_length = 1
    marker_count = 2
    repeated = 3

def decompress(characters, initial, weight, reducer, decompress_repeated):
    state = DecompressState.normal
    marker_length, marker_count, repeated = 0, 0, ''

    result = initial
    for character in characters:
        if state is DecompressState.normal:
            if character == '(':
                state = DecompressState.marker_length
            else:
                result = reducer(result, weight, character)
        elif state is DecompressState.marker_length:
            if character.isdigit():
                marker_length = marker_length * 10 + int(character)
            elif character == 'x':
                state = DecompressState.marker_count
            else:
                assert False
        elif state is DecompressState.marker_count:
            if character.isdigit():
                marker_count = marker_count * 10 + int(character)
            elif character == ')':
                state = DecompressState.repeated
            else:
                assert False
        elif state is DecompressState.repeated:
            repeated += character
            if len(repeated) == marker_length:
                if decompress_repeated:
                    result = decompress(repeated, result, weight * marker_count, reducer, decompress_repeated=True)
                else:
                    result = reducer(result, weight * marker_count, repeated)
                marker_length, marker_count, repeated = 0, 0, ''
                state = DecompressState.normal
        else:
            assert False
    return result

# test_strings = [
#     'ADVENT',
#     'A(1x5)BC',
#     '(3x3)XYZ',
#     'A(2x2)BCD(2x2)EFG',
#     '(6x1)(1x3)A',
#     'X(8x2)(3x3)ABCY',
#     '(27x12)(20x12)(13x14)(7x10)(1x12)A',
#     '(25x3)(3x3)ABC(2x3)XY(5x2)PQRSTX(18x9)(3x2)TWO(5x7)SEVEN',
# ]
# for test_string in test_strings:
#     def string_reducer(result, chars):
#         result += chars
#         return result
#     result = decompress(test_string, '', string_reducer, True)
#     print(f'{test_string} => {result}')

#     def length_reducer(result, chars):
#         result += len(chars)
#         return result
#     result = decompress(test_string, 0, length_reducer, True)
#     print(f'{test_string} => {result}')

with open('aoc09.txt', 'r') as f:
    def length_reducer(result, weight, chars):
        result += weight * len(chars)
        return result

    input_data = f.read().strip()
    length1 = decompress(input_data, 0, 1, length_reducer, False)
    length2 = decompress(input_data, 0, 1, length_reducer, True)

    print(f'Part 1: The decompressed data is {length1} characters.')
    print(f'Part 2: The decompressed data is {length2} characters.')
