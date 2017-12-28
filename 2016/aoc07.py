# --- Day 7: Internet Protocol Version 7 ---

# While snooping around the local network of EBHQ, you compile a list of IP
# addresses (they're IPv7, of course; IPv6 is much too limited). You'd like to
# figure out which IPs support TLS (transport-layer snooping).

# An IP supports TLS if it has an Autonomous Bridge Bypass Annotation, or
# ABBA. An ABBA is any four-character sequence which consists of a pair of two
# different characters followed by the reverse of that pair, such as xyyx or
# abba. However, the IP also must not have an ABBA within any hypernet
# sequences, which are contained by square brackets.

# For example:

# abba[mnop]qrst supports TLS (abba outside square brackets).

# abcd[bddb]xyyx does not support TLS (bddb is within square brackets, even
# though xyyx is outside square brackets).

# aaaa[qwer]tyui does not support TLS (aaaa is invalid; the interior characters
# must be different).

# ioxxoj[asdfgh]zxcvbn supports TLS (oxxo is outside square brackets, even
# though it's within a larger string).

# How many IPs in your puzzle input support TLS?

################################################################################

def is_tls(ip):
    def is_abba(end_index):
        ab = ip[end_index - 3: end_index - 1]
        ba = ip[end_index - 1: end_index + 1]
        reversed_ba = ''.join(reversed(ba))
        return ab == reversed_ba and ba != reversed_ba
    in_hypernet = False
    has_abba = False
    for ip_index, character in enumerate(ip):
        if character == '[':
            in_hypernet = True
        elif character == ']':
            in_hypernet = False
        elif ip_index > 2 and is_abba(ip_index):
            if in_hypernet:
                return False
            has_abba = True
    return has_abba

def is_ssl(ip):
    def repetition_at_index(end_index):
        if end_index < 2:
            return None
        a, b, a2 = ip[end_index - 2], ip[end_index - 1], ip[end_index]
        if a == a2 and a != b:
            return [a, b]
        return None
    in_hypernet = False
    aba_pairs = []
    bab_pairs = []
    for ip_index, character in enumerate(ip):
        if character == '[':
            in_hypernet = True
        elif character == ']':
            in_hypernet = False
        else:
            repetition = repetition_at_index(ip_index)
            if repetition is not None:
                if not in_hypernet:
                    aba_pairs.append(repetition)
                else:
                    bab_pairs.append(repetition)
    for aba in aba_pairs:
        if list(reversed(aba)) in bab_pairs:
            return True
    return False

with open('aoc07.txt', 'r') as f:
    ips = [ip.strip() for ip in f]
    tls_ips = list(filter(is_tls, ips))
    ssl_ips = list(filter(is_ssl, ips))
    print(f'{len(tls_ips)} support TLS.')
    print(f'{len(ssl_ips)} support SSL.')
