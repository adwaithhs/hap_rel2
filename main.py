import numpy as np
from numpy.random import rand, randint, shuffle
from math import sqrt

M = 50
R = 0.3

class Chromosome:
    def __init__(self) -> None:
        self.cs = []
        self.score = None
    def __len__(self):
        return len(self.cs)
    def __getitem__(self, key):
        return self.cs[key]
    def append(self, item):
        self.cs.append(item)
    def copy(self):
        ch = Chromosome()
        ch.cs = self.cs.copy()
        return ch

class Circle:
    def __init__(self, x, y, w) -> None:
        self.x = x
        self.y = y
        self.w = w

    def copy(self):
        return Circle(self.x, self.y, self.w)
    def has(self, x, y):
        return sqrt((x-self.x)**2 + (y-self.y)**2) <= R

def randz():
    return 2*rand() - 1

def random(pop, n, x, y):
    for _ in range(n):
        ch = Chromosome()
        for _ in range(M):
            ch.append(Circle(
                x*randz()/2,
                y*randz()/2,
                randz()
            ))
        pop.append(ch)

def mutate(pop, n, p, q, dx, dw):
    m = len(pop)
    for _ in range(n):
        i = randint(m)
        ch = Chromosome()
        for c in pop[i]:
            cc = c.copy()
            if rand() < p:
                cc.x += dx*randz()
                cc.y += dx*randz()
            if rand() < q:
                cc.w += dw*randz()
            # cc.w = cc.w/(1+dw)
            ch.append(cc)
        pop.append(ch)

def cross(pop, n):
    m = len(pop)
    for _ in range(n):
        i = randint(m)
        j = randint(m-1)
        if j>=i:
            j+=1
        if len(pop[i]) < len(pop[j]):
            temp = i
            i = j
            j = temp
        ch1 = shuffle(pop[i].copy())
        ch2 = pop[j]

        ch = []
        for k in range(len(pop[j])):
            if rand() < 0.5:
                ch.append(ch1[k].copy())
            else:
                ch.append(ch2[k].copy())

        pop.append(ch)



def score(pop, dx):
    for ch in pop:
        if ch.score != None:
            continue
        for x in range(-0.5, 0.5, dx):
            for y in range(-0.5, 0.5, dx):
                w1 = None
                w2 = None
                for c in ch.cs:
                    pass


