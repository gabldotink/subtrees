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
