import enum
import sys

class Direction(enum.Enum):
    north = 0
    east = 1
    south = 2
    west = 3

    @property
    def right(self):
        return Direction((self.value + 1) % 4)

    @property
    def left(self):
        return Direction((self.value - 1) % 4)

sys, filename = sys.argv
with open(filename, 'r') as f:
    directions = f.read().strip()
steps = [(s[:1], int(s[1:])) for s in directions.split(', ')]

direction = Direction.north
x, y = 0, 0
def total_blocks():
    return abs(x) + abs(y)    
visits = {(x, y): 1}
actual_distance = None

for turn, blocks in steps:
    if turn == 'R':
        direction = direction.right
    elif turn == 'L':
        direction = direction.left
    else:
        assert False

    while blocks > 0:
        if direction is Direction.north:
            y += 1
        elif direction is Direction.south:
            y -= 1
        elif direction is Direction.east:
            x += 1
        elif direction is Direction.west:
            x -= 1
        else:
            assert False
        
        if (x, y) not in visits:
            visits[(x, y)] = 0
        visits[(x, y)] += 1

        if actual_distance is None and visits[(x, y)] == 2:
            actual_distance = total_blocks()

        blocks -= 1

print(f'Easter Bunny HQ is {total_blocks()} blocks away.')
print(f'Actual HQ is {actual_distance} blocks away.')
