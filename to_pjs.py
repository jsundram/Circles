import re

"""convert pde to pjs. Basically the only issue is size"""

replacement = "\tsize(window.innerHeight, window.innerWidth);\n"
f = open('circles.pde')
g = open('sketch.pjs', 'w')

for line in f:
    if re.match('^\W+size.*$', line):
        line = replacement
    g.write(line)

f.close()
g.close()
