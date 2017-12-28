# --- Day 24: Electromagnetic Moat ---

# The CPU itself is a large, black building surrounded by a bottomless
# pit. Enormous metal tubes extend outward from the side of the building at
# regular intervals and descend down into the void. There's no way to cross,
# but you need to get inside.

# No way, of course, other than building a bridge out of the magnetic
# components strewn about nearby.

# Each component has two ports, one on each end. The ports come in all
# different types, and only matching types can be connected. You take an
# inventory of the components by their port types (your puzzle input). Each
# port is identified by the number of pins it uses; more pins mean a stronger
# connection for your bridge. A 3/7 component, for example, has a type-3 port
# on one side, and a type-7 port on the other.

# Your side of the pit is metallic; a perfect surface to connqect a magnetic, zero-pin port. Because of this, the first port you use must be of type 0. It doesn't matter what type of port you end with; your goal is just to make the bridge as strong as possible.

# The strength of a bridge is the sum of the port types in each component. For
# example, if your bridge is made of components 0/3, 3/7, and 7/4, your bridge
# has a strength of 0+3 + 3+7 + 7+4 = 24.

# For example, suppose you had the following components:

# 0/2
# 2/2
# 2/3
# 3/4
# 3/5
# 0/1
# 10/1
# 9/10

# With them, you could make the following valid bridges:

# 0/1
# 0/1--10/1
# 0/1--10/1--9/10
# 0/2
# 0/2--2/3
# 0/2--2/3--3/4
# 0/2--2/3--3/5
# 0/2--2/2
# 0/2--2/2--2/3
# 0/2--2/2--2/3--3/4
# 0/2--2/2--2/3--3/5

# (Note how, as shown by 10/1, order of ports within a component doesn't
# matter. However, you may only use each port on a component once.)

# Of these bridges, the strongest one is 0/1--10/1--9/10; it has a strength of
# 0+1 + 1+10 + 10+9 = 31.

# What is the strength of the strongest bridge you can make with the components
# you have available?

# --- Part Two ---

# The bridge you've built isn't long enough; you can't jump the rest of the
# way.

# In the example above, there are two longest bridges:

# 0/2--2/2--2/3--3/4
# 0/2--2/2--2/3--3/5

# Of them, the one which uses the 3/5 component is stronger; its strength is
# 0+2 + 2+2 + 2+3 + 3+5 = 19.

# What is the strength of the longest bridge you can make? If you can make
# multiple bridges of the longest length, pick the strongest one.

################################################################################

def find_bridges(ports, bridge=[], results=set()):
    if len(bridge) > 0:
        previous_port = bridge[-1][1]
    else:
        previous_port = 0
    matching_ports = [p for p in ports if previous_port in p]

    if len(matching_ports) == 0:
        results.add(tuple(bridge))
    else:
        for matching_port in matching_ports:
            next_ports = ports[:]
            next_ports.remove(matching_port)

            if matching_port[0] != previous_port:
                matching_port = tuple(reversed(matching_port))
            next_bridge = bridge + [matching_port]

            find_bridges(next_ports, next_bridge, results)

    return results

def strength(bridge):
    return sum(map(sum, bridge))

def parse_ports(ports):
    def parse_line(line):
        return tuple(sorted(map(int, line.split('/'))))
    return list(sorted([parse_line(l) for l in ports.strip().splitlines()]))

with open('aoc24.txt', 'r') as f:
    ports_input = f.read()
ports = parse_ports(ports_input)
bridges = find_bridges(ports)

max_strength = max(map(strength, bridges))
print(f'Part 1: The strongest bridge is {max_strength} units.')

strongest = None
for bridge in bridges:
    bridge_strength = strength(bridge)
    if strongest is None:
        strongest = bridge
    elif len(bridge) > len(strongest):
        strongest = bridge
    elif len(bridge) == len(strongest) and strength(bridge) > strength(strongest):
        strongest = bridge
max_strength = strength(strongest)
print(f'Part 2: The strongest longest bridge is {max_strength} units.')
