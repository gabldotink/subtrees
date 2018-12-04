import glob
import os
from combinearc import merge_hrx

path = 'test/*.hrx'
files = [fn for fn in glob.glob(path) if not os.path.isdir(fn)]
print(merge_hrx(files))
