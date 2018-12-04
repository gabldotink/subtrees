from fs.memoryfs import MemoryFS
import pprint
import sys
import hrx2


mem_fs = MemoryFS()
fname = "test/simple.hrx"
file = open(fname, "r")

result = hrx2.parse(file.read())
for key,val in result.items():
    if not mem_fs.exists(key):
        if val["isDirectory"]:
            mem_fs.makedirs(key)
        else:
            if not mem_fs.exists(key.rsplit('/', 1)[0] + '/') and '/' in key:
                mem_fs.makedirs(key.rsplit('/', 1)[0] + '/')
            mem_fs.settext(key,val["fileContents"])

#mem_fs.tree()
print(mem_fs.gettext("output.css"))
