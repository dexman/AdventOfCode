# --- Day 20: Particle Swarm ---

# Suddenly, the GPU contacts you, asking for help. Someone has asked it to
# simulate too many particles, and it won't be able to finish them all in time
# to render the next frame at this rate.

# It transmits to you a buffer (your puzzle input) listing each particle in
# order (starting with particle 0, then particle 1, particle 2, and so on). For
# each particle, it provides the X, Y, and Z coordinates for the particle's
# position (p), velocity (v), and acceleration (a), each in the format <X,Y,Z>.

# Each tick, all particles are updated simultaneously. A particle's properties
# are updated in the following order:

# Increase the X velocity by the X acceleration.
# Increase the Y velocity by the Y acceleration.
# Increase the Z velocity by the Z acceleration.
# Increase the X position by the X velocity.
# Increase the Y position by the Y velocity.
# Increase the Z position by the Z velocity.

# Because of seemingly tenuous rationale involving z-buffering, the GPU would
# like to know which particle will stay closest to position <0,0,0> in the long
# term. Measure this using the Manhattan distance, which in this situation is
# simply the sum of the absolute values of a particle's X, Y, and Z position.

# For example, suppose you are only given two particles, both of which stay
# entirely on the X-axis (for simplicity). Drawing the current states of
# particles 0 and 1 (in that order) with an adjacent a number line and diagram
# of current X positions (marked in parenthesis), the following would take
# place:

# p=< 3,0,0>, v=< 2,0,0>, a=<-1,0,0>    -4 -3 -2 -1  0  1  2  3  4
# p=< 4,0,0>, v=< 0,0,0>, a=<-2,0,0>                         (0)(1)

# p=< 4,0,0>, v=< 1,0,0>, a=<-1,0,0>    -4 -3 -2 -1  0  1  2  3  4
# p=< 2,0,0>, v=<-2,0,0>, a=<-2,0,0>                      (1)   (0)

# p=< 4,0,0>, v=< 0,0,0>, a=<-1,0,0>    -4 -3 -2 -1  0  1  2  3  4
# p=<-2,0,0>, v=<-4,0,0>, a=<-2,0,0>          (1)               (0)

# p=< 3,0,0>, v=<-1,0,0>, a=<-1,0,0>    -4 -3 -2 -1  0  1  2  3  4
# p=<-8,0,0>, v=<-6,0,0>, a=<-2,0,0>                         (0)

# At this point, particle 1 will never be closer to <0,0,0> than particle 0,
# and so, in the long run, particle 0 will stay closest.

# Which particle will stay closest to position <0,0,0> in the long term?

# --- Part Two ---

# To simplify the problem further, the GPU would like to remove any particles
# that collide. Particles collide if their positions ever exactly
# match. Because particles are updated simultaneously, more than two particles
# can collide at the same time and place. Once particles collide, they are
# removed and cannot collide with anything else after that tick.

# For example:

# p=<-6,0,0>, v=< 3,0,0>, a=< 0,0,0>    
# p=<-4,0,0>, v=< 2,0,0>, a=< 0,0,0>    -6 -5 -4 -3 -2 -1  0  1  2  3
# p=<-2,0,0>, v=< 1,0,0>, a=< 0,0,0>    (0)   (1)   (2)            (3)
# p=< 3,0,0>, v=<-1,0,0>, a=< 0,0,0>

# p=<-3,0,0>, v=< 3,0,0>, a=< 0,0,0>    
# p=<-2,0,0>, v=< 2,0,0>, a=< 0,0,0>    -6 -5 -4 -3 -2 -1  0  1  2  3
# p=<-1,0,0>, v=< 1,0,0>, a=< 0,0,0>             (0)(1)(2)      (3)   
# p=< 2,0,0>, v=<-1,0,0>, a=< 0,0,0>

# p=< 0,0,0>, v=< 3,0,0>, a=< 0,0,0>    
# p=< 0,0,0>, v=< 2,0,0>, a=< 0,0,0>    -6 -5 -4 -3 -2 -1  0  1  2  3
# p=< 0,0,0>, v=< 1,0,0>, a=< 0,0,0>                       X (3)      
# p=< 1,0,0>, v=<-1,0,0>, a=< 0,0,0>

# ------destroyed by collision------    
# ------destroyed by collision------    -6 -5 -4 -3 -2 -1  0  1  2  3
# ------destroyed by collision------                      (3)         
# p=< 0,0,0>, v=<-1,0,0>, a=< 0,0,0>

# In this example, particles 0, 1, and 2 are simultaneously destroyed at the
# time and place marked X. On the next tick, particle 3 passes through
# unharmed.

# How many particles are left after all collisions are resolved?

################################################################################

import collections

Point = collections.namedtuple('Point', [
    'x',
    'y',
    'z',
])
Point.distance = lambda self: sum(map(abs, self))

Particle = collections.namedtuple('Particle', [
    'id',
    'p',
    'v',
    'a',
])
Particle.distance = lambda self: self.p.distance()

def simulate(particles, ticks, remove_collisions):
    def simulate_particle(particle):
        v = Point(*[sum(t) for t in zip(particle.v, particle.a)])
        p = Point(*[sum(t) for t in zip(particle.p, v)])
        return Particle(particle.id, p, v, particle.a)
    def filter_collisions(particles):
        seen = collections.defaultdict(list)
        for particle in particles:
            seen[particle.p].append(particle)
        return [p[0] for _, p in seen.items() if len(p) == 1]
    def tick(particles):
        return [simulate_particle(p) for p in particles]

    for t in range(ticks):
        particles = tick(particles)
        if remove_collisions:
            particles = filter_collisions(particles)
    return particles

def parse_particles(particles_input):
    def parse_xyz(xyz_input):
        return Point(*[int(n) for n in xyz_input[1:-1].split(',')])
    def parse_particle(id, particle_input):
        components = [i.split('=') for i in particle_input.split(', ')]
        p, v, a = [parse_xyz(c[1]) for c in components]
        return Particle(id, p, v, a)
    lines = particles_input.strip().splitlines()
    return [parse_particle(id, l) for id, l in enumerate(lines)]

with open('aoc20.txt', 'r') as f:
    particles_input = f.read()
particles = parse_particles(particles_input)
particles1 = simulate(particles, ticks=1000, remove_collisions=False)
closest_particle = min(particles1, key=Particle.distance)
print(f'Part 1: Closest particle to (0,0,0) is {closest_particle.id}.')

particles2 = simulate(particles, ticks=1000, remove_collisions=True)
print(f'Part 2: {len(particles2)} particles left after removing collisions.')
