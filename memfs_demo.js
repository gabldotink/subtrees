const fsx = require('fs');
const memfs = require('memfs');
const parse_hrx = require('./hrx.js')

var contents = fsx.readFileSync('web.hrx', 'utf8').replace(/\r/gm,"");
const vol = memfs.Volume.fromJSON(parse_hrx(contents)[0], "/");
console.log(vol.toJSON())
