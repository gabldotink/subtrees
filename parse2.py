import pprint
import hrx2
import sys

fname = sys.argv[1]
file = open(fname, "r")

(result,err) = hrx2.parse(file.read())

print("==== Parser Attempt ====")
pp = pprint.PrettyPrinter(depth=6)
pp.pprint(result)
print("\n==== Parser Errors ====")
hrx2.print_errors(err)
