import re
import sys

def row_difference(row):
    if len(row) == 0:
        return 0
    return max(row) - min(row)

def checksum_part1(rows):
    return sum(map(row_difference, rows))

def row_dividers(row):
    row = sorted(row)
    def perform(row):
        if len(row) == 0:
            return 0
        head, *tail = sorted(row)
        for n in tail:
            if n % head == 0:
                return n // head
        return row_dividers(tail)
    return perform(row)

def checksum_part2(rows):
    return sum(map(row_dividers, rows))

def parse_rows(input):
    row_strings = input.strip().split('\n')
    def parse_row(row_string):
        row_string = row_string.strip()
        if len(row_string) == 0:
            return []
        column_strings = re.split('\\s+', row_string)
        return list(map(int, column_strings))
    return list(map(parse_row, row_strings))

if __name__ == '__main__':
    _, filename = sys.argv
    with open(filename, 'r') as f:
        rows = parse_rows(f.read())
        print(f'Part 1 Checksum: {checksum_part1(rows)}')
        print(f'Part 2 Checksum: {checksum_part2(rows)}')
