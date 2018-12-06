import pprint
import hrx
import sys

fname = sys.argv[1]
file = open(fname, "r")

result = hrx.parse(file.read())

pp = pprint.PrettyPrinter(depth=6)
pp.pprint(result)
