import pprint
import hrx2
fname = sys.argv[1]
file = open(fname, "r")

result = hrx2.parse(file.read())

pp = pprint.PrettyPrinter(depth=6)
pp.pprint(result)
