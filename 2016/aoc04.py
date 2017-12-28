# --- Day 4: Security Through Obscurity ---
#
# Finally, you come across an information kiosk with a list of rooms. Of
# course, the list is encrypted and full of decoy data, but the instructions to
# decode the list are barely hidden nearby. Better remove the decoy data first.
#
# Each room consists of an encrypted name (lowercase letters separated by
# dashes) followed by a dash, a sector ID, and a checksum in square brackets.
#
# A room is real (not a decoy) if the checksum is the five most common letters
# in the encrypted name, in order, with ties broken by alphabetization. For
# example:
#
# - aaaaa-bbb-z-y-x-123[abxyz] is a real room because the most common letters
#   are a (5), b (3), and then a tie between x, y, and z, which are listed
#    alphabetically.
# - a-b-c-d-e-f-g-h-987[abcde] is a real room because although the letters are
#   all tied (1 of each), the first five are listed alphabetically.
# - not-a-real-room-404[oarel] is a real room.
# - totally-real-room-200[decoy] is not.
#
# Of the real rooms from the list above, the sum of their sector IDs is 1514.
#
# What is the sum of the sector IDs of the real rooms?

################################################################################

import collections
import sys

def most_common_letters(name, n):
    letter_frequencies = collections.defaultdict(int)
    for letter in [char for char in name if char.isalpha()]:
        letter_frequencies[letter] += 1

    # (letter, frequency) pairs, unsorted.
    letter_frequencies = letter_frequencies.items()

    # Sort by letter first to break ties.
    most_common = sorted(letter_frequencies, key=lambda i: i[0])

    # Sort by decreasing frequency.
    most_common = sorted(most_common, key=lambda i: i[1], reverse=True)

    most_common = most_common[:n]
    return ''.join([letter for letter, _ in most_common])

def is_real_room(room):
    name, _, checksum = room
    return most_common_letters(name, 5) == checksum

def decrypt(room):
    name, sector_id, checksum = room
    def decrypt_letter(letter):
        if not letter.isalpha():
            return ' '
        return chr((ord(letter) - ord('a') + sector_id) % 26 + ord('a'))
    decrypted_name = ''.join(map(decrypt_letter, name))
    return (decrypted_name, sector_id, checksum)

def parse_rooms(rooms):
    '''Returns list of (name, sector_id, checksum) pairs.'''
    def parse_room(line):
        return line[:-11], int(line[-10:-7]), line[-6:-1]
    lines = rooms.strip().split('\n')
    return map(parse_room, lines)

_, filename = sys.argv
with open(filename, 'r') as f:
    rooms = parse_rooms(f.read())
    real_rooms = list(filter(is_real_room, rooms))
    sector_ids = [sector_id for _, sector_id, _ in real_rooms]
    decrypted_rooms = list(map(decrypt, real_rooms))
    print(f'There are {sum(sector_ids)} real rooms.')
    for name in decrypted_rooms:
        print(name)
