# --- Day 6: Signals and Noise ---

# Something is jamming your communications with Santa. Fortunately, your signal
# is only partially jammed, and protocol in situations like this is to switch
# to a simple repetition code to get the message through.

# In this model, the same message is sent repeatedly. You've recorded the
# repeating message signal (your puzzle input), but the data seems quite
# corrupted - almost too badly to recover. Almost.

# All you need to do is figure out which character is most frequent for each
# position. For example, suppose you had recorded the following messages:

# eedadn
# drvtee
# eandsr
# raavrd
# atevrs
# tsrnev
# sdttsa
# rasrtv
# nssdts
# ntnada
# svetve
# tesnvt
# vntsnd
# vrdear
# dvrsen
# enarar

# The most common character in the first column is e; in the second, a; in the
# third, s, and so on. Combining these characters returns the error-corrected
# message, easter.

# Given the recording in your puzzle input, what is the error-corrected version
# of the message being sent?

################################################################################

from collections import Counter

def error_corrected_message_part1(messages):
    if len(messages) == 0:
        return ''

    def error_corrected_character(character_index):
        frequencies = Counter(map(lambda m: m[character_index], messages))
        character, *_ = frequencies.most_common(1)[0]
        return character

    message_length = len(messages[0])
    return ''.join(map(error_corrected_character, range(message_length)))

def error_corrected_message_part2(messages):
    if len(messages) == 0:
        return ''

    def error_corrected_character(character_index):
        frequencies = Counter(map(lambda m: m[character_index], messages))
        character, *_ = frequencies.most_common()[-1]
        return character

    message_length = len(messages[0])
    return ''.join(map(error_corrected_character, range(message_length)))

with open('aoc06.txt', 'r') as f:
    messages = f.read().strip().split('\n')
    print(f'Part 1: {error_corrected_message_part1(messages)}')
    print(f'Part 2: {error_corrected_message_part2(messages)}')
