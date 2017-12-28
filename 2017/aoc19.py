# --- Day 19: A Series of Tubes ---

# Somehow, a network packet got lost and ended up here. It's trying to follow a
# routing diagram (your puzzle input), but it's confused about where to go.

# Its starting point is just off the top of the diagram. Lines (drawn with |,
# -, and +) show the path it needs to take, starting by going down onto the
# only line connected to the top of the diagram. It needs to follow this path
# until it reaches the end (located somewhere within the diagram) and stop
# there.

# Sometimes, the lines cross over each other; in these cases, it needs to
# continue going the same direction, and only turn left or right when there's
# no other option. In addition, someone has left letters on the line; these
# also don't change its direction, but it can use them to keep track of where
# it's been. For example:

#      |          
#      |  +--+    
#      A  |  C    
#  F---|----E|--+ 
#      |  |  |  D 
#      +B-+  +--+ 

# Given this diagram, the packet needs to take the following path:

# Starting at the only line touching the top of the diagram, it must go down,
# pass through A, and continue onward to the first +.

# Travel right, up, and right, passing through B in the process.

# Continue down (collecting C), right, and up (collecting D).

# Finally, go all the way left through E and stopping at F.

# Following the path to the end, the letters it sees on its path are ABCDEF.

# The little packet looks up at you, hoping you can help it find the way. What
# letters will it see (in the order it would see them) if it follows the path?
# (The routing diagram is very wide; make sure you view it without line
# wrapping.)

# --- Part Two ---

# The packet is curious how many steps it needs to go.

# For example, using the same routing diagram from the example above...

#      |          
#      |  +--+    
#      A  |  C    
#  F---|--|-E---+ 
#      |  |  |  D 
#      +B-+  +--+ 

# ...the packet would go:

# 6 steps down (including the first line at the top of the diagram).
# 3 steps right.
# 4 steps up.
# 3 steps right.
# 4 steps down.
# 3 steps right.
# 2 steps up.
# 13 steps left (including the F it stops on).
# This would result in a total of 38 steps.

# How many steps does the packet need to go?

################################################################################

import collections
import enum

class Direction(enum.Enum):
    up = 1
    down = 2
    left = 3
    right = 4

    @property
    def perpendicular_directions(self):
        if self is Direction.up or self is Direction.down:
            return [Direction.left, Direction.right]
        else:
            return [Direction.down, Direction.up]

class Coordinate:
    def __init__(self, x, y):
        self.x = x
        self.y = y

    def __str__(self):
        return f'({self.x},{self.y})'

    def moved(self, direction):
        next_coordinate = Coordinate(self.x, self.y)
        if direction == Direction.down:
            next_coordinate.y += 1
        elif direction == Direction.up:
            next_coordinate.y -= 1
        elif direction == Direction.left:
            next_coordinate.x -= 1
        elif direction == Direction.right:
            next_coordinate.x += 1
        return next_coordinate

class Maze:
    def __init__(self, maze):
        self.maze = maze.splitlines()
        assert len(self.maze) > 0
        assert len(self.maze[0]) > 0
        lengths_match = map(lambda r: len(self.maze[0]) == len(r), self.maze)
        assert False not in lengths_match

    @property
    def starting_coordinate(self):
        coordinate = Coordinate(0, 0)
        coordinate.x = self.maze[0].index('|')
        return coordinate

    @property
    def width(self):
        return len(self.maze[0])
    
    @property
    def height(self):
        return len(self.maze)

    def __str__(self):
        return '\n'.join(self.maze)

    def __getitem__(self, coordinate):
        if coordinate.x < 0 or coordinate.x >= self.width:
            return None
        if coordinate.y < 0 or coordinate.y >= self.height:
            return None
        cell = self.maze[coordinate.y][coordinate.x]
        return cell if cell != ' ' else None

def follow_maze(maze):
    coordinate = maze.starting_coordinate
    direction = Direction.down
    labels_seen = []
    steps = 0

    while True:
        if maze[coordinate] == '+':
            if not maze[coordinate.moved(direction)]:
                for new_direction in direction.perpendicular_directions:
                    if maze[coordinate.moved(new_direction)]:
                        direction = new_direction
                        break
        elif maze[coordinate].isalpha():
            labels_seen.append(maze[coordinate])
        coordinate = coordinate.moved(direction)
        steps += 1
        if not maze[coordinate]:
            break

    return ''.join(labels_seen), steps

with open('aoc19.txt', 'r') as f:
    maze = Maze(f.read())
path, steps = follow_maze(maze)
print(f'Part 1: The path taken is {path}.')
print(f'Part 2: The number of steps taken is {steps}.')
