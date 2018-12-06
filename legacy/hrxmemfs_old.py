__copyright__ = """

    Copyright 2018 Rebecca Pruim

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

"""
__license__ = "Apache 2.0"

from fs.memoryfs import MemoryFS
import pprint
import sys
import hrx


mem_fs = MemoryFS()
fname = "test/simple.hrx"
file = open(fname, "r")

result = hrx.parse(file.read())
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
