import sys

KEYPAD_1 = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
]

KEYPAD_2 = [
    [None, None,  '1', None, None],
    [None,  '2',  '3',  '4', None],
    [ '5',  '6',  '7',  '8',  '9'],
    [None,  'A',  'B',  'C', None],
    [None, None,  'D', None, None],
]

def button(keypad, coord):
    if coord[1] < 0 or coord[1] >= len(keypad):
        return None
    row = keypad[coord[1]]
    if coord[0] < 0 or coord[0] >= len(row):
        return None
    return row[coord[0]]

def move_coordinate_up(coord):
    return (coord[0], coord[1] - 1)

def move_coordinate_down(coord):
    return (coord[0], coord[1] + 1)

def move_coordinate_left(coord):
    return (coord[0] - 1, coord[1])

def move_coordinate_right(coord):
    return (coord[0] + 1, coord[1])

def move_coordinate(keypad, coordinate, direction):
    if direction == 'U':
        new_coord = move_coordinate_up(coordinate)
    elif direction == 'D':
        new_coord = move_coordinate_down(coordinate)
    elif direction == 'L':
        new_coord = move_coordinate_left(coordinate)
    elif direction == 'R':
        new_coord = move_coordinate_right(coordinate)
    else:
        assert False

    if button(keypad, new_coord) is None:
        return coordinate
    return new_coord

def find_button(keypad, button):
    for y, row in enumerate(keypad):
        for x, column in enumerate(row):
            if column == button:
                return (x, y)
    return None

def decode_instructions(keypad, instructions):
    coordinate = find_button(keypad, '5')
    assert coordinate is not None

    digits = ''
    for line in instructions.strip().split('\n'):
        for move in line:
            coordinate = move_coordinate(keypad, coordinate, move)
        digits += button(keypad, coordinate)
    return digits

_, filename = sys.argv
with open(filename, 'r') as f:
    instructions = f.read()
    print(f'Part 1 Code: {decode_instructions(KEYPAD_1, instructions)}')
    print(f'Part 2 Code: {decode_instructions(KEYPAD_2, instructions)}')
