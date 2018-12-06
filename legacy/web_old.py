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

from flask import Flask, Response
from fs.memoryfs import MemoryFS
import pprint
import sys
import hrx2

mem_fs = MemoryFS()
fname = "test/web.hrx"
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

app = Flask(__name__)

@app.route('/', defaults={'path': ''})
@app.route('/<path:path>')
def serve_file(path):
    if not path:
        path = "index.html"

    if mem_fs.exists(path):
        if "css" in path:
            return Response(mem_fs.gettext(path), status=200, mimetype="text/css")
        else:
            return Response(mem_fs.gettext(path), status=200, mimetype="text/html")
    else:
        return Response("Not Found", status=404, mimetype="text/plain")


if __name__ == '__main__':
    app.run()
