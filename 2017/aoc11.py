def navigate(coordinate, direction):
    x, y, z = coordinate
    if direction == 'n':
        y += 1
        z -= 1
    elif direction == 'ne':
        x += 1
        z -= 1
    elif direction == 'se':
        x += 1
        y -= 1
    elif direction == 's':
        y -= 1
        z += 1
    elif direction == 'sw':
        x -= 1
        z += 1
    elif direction == 'nw':
        x -= 1
        y += 1
    else:
        assert False
    return x, y, z

def distance(coordinate):
    x, y, z = coordinate
    return (abs(x) + abs(y) + abs(z)) // 2

def parse_input(input):
    return input.strip().split(',')

with open('aoc11.txt', 'r') as f:
    directions = parse_input(f.read())

coordinate = 0, 0, 0
max_dist = 0
for direction in directions:
    coordinate = navigate(coordinate, direction)
    max_dist = max(max_dist, distance(coordinate))
dist = distance(coordinate)
print(f'Part 1: The distance from origin is: {dist}')
print(f'Part 2: The maximum ever distance from origin is: {max_dist}')
