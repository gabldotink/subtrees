import glob
import os
from subarc import create_sub_hrx

path = 'test/*.hrx'
files = [fn for fn in glob.glob(path) if not os.path.isdir(fn)]
print(create_sub_hrx(files))
