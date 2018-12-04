import glob
import os
import hrx2

path = 'test/*.hrx'
files = [fn for fn in glob.glob(path) if not os.path.isdir(fn)]
print(hrx2.pack(files))
