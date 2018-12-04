import sys
import glob
import errno
from hrx import parse_hrx
import pprint

pp = pprint.PrettyPrinter(depth=6)

path = 'test/*.hrx'
files = glob.glob(path)
for name in files:
    try:
        with open(name) as f:
            print("==== " + name + " ====")
            pp.pprint(parse_hrx(f.read()))
    except IOError as exc:
        if exc.errno != errno.EISDIR:
            raise
