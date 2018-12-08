const fsx = require('fs');
const memfs = require('memfs');
const parse_hrx = require('./hrx.js')
const intercept = require("intercept-require");

//Read in the archive
var contents = fsx.readFileSync('web.hrx', 'utf8').replace(/\r/gm,"");
const vol = memfs.Volume.fromJSON(parse_hrx(contents)[0], "/");
const hrx_fs = memfs.createFsFromVolume(vol);

//Generate a utility to intercept requires for the send module.
//Replace them with a patched version that lets you pass a different fs object
const restore = intercept(function (moduleExport, info) {
  if(info.moduleId == "send"){
    moduleExport = require("./send_inject");
    moduleExport.fsSwap(hrx_fs);
  }
  return moduleExport;
}, null);

//App Code (I've only tested this with static serving.)
const express = require('express');
var app = express();
app.use("/", express.static('/'));
app.listen(3000);
