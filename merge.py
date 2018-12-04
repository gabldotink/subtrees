import glob
import os
from merge_lib import merge_hrx

path = 'test/*.hrx'
files = [fn for fn in glob.glob(path) if not os.path.isdir(fn)]
print(merge_hrx(files))
