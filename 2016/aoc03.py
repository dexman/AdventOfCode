import itertools
import re
import sys

def is_triangle(sides):
    assert len(sides) == 3
    sides = sorted(sides)
    return sides[0] + sides[1] > sides[2]
        
def parse_triangles_part1(string):
    def parse_line(line):
        return list(map(int, re.split('\\s+', line.strip())))
    return list(map(parse_line, string.strip().split('\n')))

def parse_triangles_part2(string):
    result = []
    triangles = [[], [], []]
    for line in string.strip().split('\n'):
        sides = list(map(int, re.split('\\s+', line.strip())))
        for t, s in zip(triangles, sides):
            t.append(s)
        if len(triangles[0]) == 3:
            result += triangles
            triangles = [[], [], []]
    return result

with open('aoc03.txt', 'r') as f:
    input_string = f.read()
    triangles1 = parse_triangles_part1(input_string)
    possible1 = len(list(filter(is_triangle, triangles1)))

    triangles2 = parse_triangles_part2(input_string)
    possible2 = len(list(filter(is_triangle, triangles2)))

    print(f'Part 1: {possible1} of {len(triangles1)} triangles are possible.')
    print(f'Part 2: {possible2} of {len(triangles2)} triangles are possible.')
