const fsx = require('fs');
const memfs = require('memfs');
const parse_hrx = require('./hrx.js')
const http = require('http');
const url = require('url');
const path = require('path');

const contents = fsx.readFileSync('web.hrx', 'utf8').replace(/\r/gm,"");
const [hrx_parsed, errs] = parse_hrx(contents);
if(errs.length)
  console.error(errs[1]);
const vol = memfs.Volume.fromJSON(hrx_parsed, "/");
const fs = memfs.createFsFromVolume(vol);


http.createServer(function(req, res){
  var fetch_path = url.parse(req.url).path

  const mimetypes = { 'css' : 'text/css', 'html': 'text/html'};
  fs.exists(fetch_path, function(exist_flag){
    if(!exist_flag){
        res.statusCode = 404;
        res.end('404: File not found.');
        return;
    }
    if(fetch_path == "/")
      fetch_path = "/index.html";

    const file_ext = fetch_path.split(/\./).pop();
    fs.readFile(fetch_path, function(err, dat){
      if(err){
        res.statusCode = 500;
        res.end('500: Internal server error.');
        console.log(err);
      }else{
        res.setHeader('Content-type', mimetypes[file_ext] || 'text/plain' );
        res.end(dat);
      }
    })

  });
}).listen(5000);
