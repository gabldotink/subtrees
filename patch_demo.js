const fsx = require('fs');
const memfs = require('memfs');
const parse_hrx = require('./hrx.js');

var contents = fsx.readFileSync('patch.hrx', 'utf8').replace(/\r/gm,"");
const vol = memfs.Volume.fromJSON(parse_hrx(contents)[0], "/");

const testFunction = vol_require(vol, '/mymodule.js')
console.log(testFunction("Test User"));


function vol_require(vol, path){
  //This uses some weirdness about NodeJS, require, and importing stuff.
  //https://fredkschott.com/post/2014/06/require-and-the-module-system/
  var modulesrc = vol.readFileSync(path, 'utf8');
  const wrapper = require('module').wrapper
  modulesrc = wrapper[0] + "\n" + modulesrc + "\nreturn module.exports;\n" + wrapper[1]
  const resultReq = eval(modulesrc)(module.exports, require, module, path.split(/[\/]+/).pop(), path);
  return resultReq;
}
