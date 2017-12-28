# --- Day 3: Spiral Memory ---

# You come across an experimental new kind of memory stored on an infinite
# two-dimensional grid.

# Each square on the grid is allocated in a spiral pattern starting at a
# location marked 1 and then counting up while spiraling outward. For example,
# the first few squares are allocated like this:

# 17  16  15  14  13
# 18   5   4   3  12
# 19   6   1   2  11
# 20   7   8   9  10
# 21  22  23---> ...
#
# While this is very space-efficient (no squares are skipped), requested data
# must be carried back to square 1 (the location of the only access port for
# this memory system) by programs that can only move up, down, left, or
# right. They always take the shortest path: the Manhattan Distance between te
# location of the data and square 1.

# For example:

# Data from square 1 is carried 0 steps, since it's at the access port.
# Data from square 12 is carried 3 steps, such as: down, left, left.
# Data from square 23 is carried only 2 steps: up twice.
# Data from square 1024 must be carried 31 steps.
# How many steps are required to carry the data from the square identified in
# your puzzle input all the way to the access port?

# Your puzzle input is 277678.

#############################################################################

# Treat square `1` as coordinate (0, 0) on an (x, y) plane.s

# 37  36  35  34  33  32  31
# 38  17  16  15  14  13  30
# 39  18   5   4   3  12  29
# 40  19   6   1   2  11  28
# 41  20   7   8   9  10  27
# 42  21  22  23  24  25  26
# 43  44  45  46  47  48  49

import collections
import math

Point = collections.namedtuple('Point', ['x', 'y'])

def ring_for_square(square):
    ring = math.ceil((math.sqrt(square) - 1) / 2)
    assert ring >= 0
    return ring

def range_for_ring(ring):
    ring_min = 1 + (2 * (ring - 1) + 1) ** 2
    ring_max = (2 * ring + 1) ** 2
    return ring_min, ring_max

def quadrant_for_square(square, ring):
    if square == 1:
        return 0
    ring_min, ring_max = range_for_ring(ring)
    quad_length = (ring_max - ring_min + 1) // 4
    quadrant = (square - ring_min) // quad_length
    assert quadrant >= 0 and quadrant < 4
    return quadrant    

def quadrant_min_for_ring(ring, quadrant):
    ring_min, ring_max = range_for_ring(ring)
    quad_size = (ring_max - ring_min + 1) // 4
    return quadrant * quad_size + ring_min

def point_for_square(square):
    assert square > 0
    ring = ring_for_square(square)
    quadrant = quadrant_for_square(square, ring)
    quad_min = quadrant_min_for_ring(ring, quadrant)
    if quadrant == 0:
        point = Point(ring, (square - quad_min - ring + 1))
    elif quadrant == 1:
        point = Point((quad_min - square + ring - 1), ring)
    elif quadrant == 2:
        point = Point(-ring, (quad_min - square + ring - 1))
    elif quadrant == 3:
        point  = Point((square - quad_min - ring + 1), -ring)
    assert point.x >= -ring and point.x <= ring 
    assert point.y >= -ring and point.y <= ring 
    return point

def distance_for_point(point):
    return abs(point.x) + abs(point.y)

def distance_for_square(square):
    assert square > 0
    if square == 1:
        return 0
    point = point_for_square(square)
    return distance_for_point(point)

# Part 1

squares = [1, 12, 14, 18, 23, 1024, 277678]
distances = map(distance_for_square, squares)

for square, distance in zip(squares, distances):
    print(f'Data from square {square} is carried {distance} steps.')

# Part 2

stress_test_values = collections.defaultdict(lambda: 0, {})
for square in range(1, 277678):
    point = point_for_square(square)
    if square == 1:
        stress_test_values[point] = 1
        continue

    value = 0
    for delta_x in range(-1, 2):
        for delta_y in range(-1, 2):
            adjacent_point = Point(point.x + delta_x, point.y + delta_y)
            value += stress_test_values[adjacent_point]
    stress_test_values[point] = value

    if value > 277678:
        print(f'First value larger than puzzle input: {value}')
        break
