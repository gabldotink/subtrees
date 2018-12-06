import glob
import os
import hrx

path = 'test/*.hrx'
files = [fn for fn in glob.glob(path) if not os.path.isdir(fn)]
print(hrx.merge(files))
