# --- Day 5: How About a Nice Game of Chess? ---

# You are faced with a security door designed by Easter Bunny engineers that
# seem to have acquired most of their security knowledge by watching hacking
# movies.

# The eight-character password for the door is generated one character at a
# time by finding the MD5 hash of some Door ID (your puzzle input) and an
# increasing integer index (starting with 0).

# A hash indicates the next character in the password if its hexadecimal
# representation starts with five zeroes. If it does, the sixth character in
# the hash is the next character of the password.

# For example, if the Door ID is abc:

# The first index which produces a hash that starts with five zeroes is
# 3231929, which we find by hashing abc3231929; the sixth character of the
# hash, and thus the first character of the password, is 1.

# 5017308 produces the next interesting hash, which starts with 000008f82...,
# so the second character of the password is 8.

# The third time a hash starts with five zeroes is for abc5278568, discovering
# the character f.

# In this example, after continuing this search a total of eight times, the
# password is 18f47a30.

# Given the actual Door ID, what is the password?

################################################################################

import hashlib
import multiprocessing

def door_code_part1(door_id):
    code = ''
    index = 0
    while len(code) < 8:
        value = f'{door_id}{index}'.encode()
        digest = hashlib.md5(value).hexdigest()
        if digest.startswith('00000'):
            code += digest[5]
        index += 1
    return code

def door_code_part2(door_id):
    code = [None] * 8
    index = 0
    while None in code:
        value = f'{door_id}{index}'.encode()
        digest = hashlib.md5(value).hexdigest()
        if digest.startswith('00000'):
            try:
                code_index = int(digest[5])
            except ValueError:
                pass
            if code_index < len(code) and code[code_index] is None:
                code[code_index] = digest[6]
        index += 1
    return ''.join(code)

print(f'The first door code is {door_code_part1("uqwqemis")}')
print(f'The second door code is {door_code_part2("uqwqemis")}')
