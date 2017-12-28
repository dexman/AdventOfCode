# --- Day 4: High-Entropy Passphrases ---

# A new system policy has been put in place that requires all accounts to use
# a passphrase instead of simply a password. A passphrase consists of a
# series of words (lowercase letters) separated by spaces.

# To ensure security, a valid passphrase must contain no duplicate words.

# For example:

# aa bb cc dd ee is valid.
# aa bb cc dd aa is not valid - the word aa appears more than once.
# aa bb cc dd aaa is valid - aa and aaa count as different words.
# The system's full passphrase list is available as your puzzle input. How
# many passphrases are valid?

################################################################################

import re
import sys

def passphrase_words(passphrase):
    return  re.split('\\s+', passphrase)
def is_valid_passphrase_part1(passphrase):
    words = passphrase_words(passphrase)
    unique_words = set(words)
    return len(words) == len(unique_words)

def is_valid_passphrase_part2(passphrase):
    words = passphrase_words(passphrase)
    def sort_word_characters(word):
        return ''.join(sorted(word))
    unique_words = set(map(sort_word_characters, words))
    return len(words) == len(unique_words)

def num_valid_passphrases(is_valid_passphrase, passphrases):
    return len(list(filter(is_valid_passphrase, passphrases)))

_, filename = sys.argv
with open(filename, 'r') as f:
    passphrases = f.read().strip().split('\n')
    num_valid_part1 = num_valid_passphrases(
        is_valid_passphrase_part1,
        passphrases)
    num_valid_part2 = num_valid_passphrases(
        is_valid_passphrase_part2,
        passphrases)

    print(f'Part 1: There are {num_valid_part1} valid passphrases.')
    print(f'Part 2: There are {num_valid_part2} valid passphrases.')
