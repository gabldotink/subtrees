function parse_hrx(contents){
  var errlist = [];
  const block_re = /((<=+>)(( |\n)(("(?:[^"\\]|\\[^\u0000-\u001F\u007F\u003A\u005C\u000A])*")|[^\u0000-\u001F\u007F\u003A\u005C\u000A]*)(?=\n)?[\S\s]+?(?=\2|$)))/g;
  const comment_re = /^<=+>\n/;
  const seq_comments_re = /^(<=+>\n.*\n+){2,}/g;
  const filename_validator_re = /^<=+> "?(\.?[^\u0000-\u001F\u007F\u003A\u005C\u000A\u002F\u002E])((?!\/\/|\/\.{1,2}\/)[^\u0000-\u001F\u007F\u003A\u005C\u000A"]|\\")*"?\n/;
  const header_re = /^<=+> /
  const dequote_re = /(^"|"$)/;
  const unescape_re = /\\(?=")/g;
  const blocks = contents.match(block_re);
  const nonblocks_arr = contents.replace(block_re, "\u0001").split("\u0001").filter(Boolean); //This should be empty.
  if(Array.isArray(nonblocks_arr) && nonblocks_arr.length){
    nonblocks_arr.forEach( item => {errlist.push("Malformed block. Near \"" + item.split(/\n([\s\S]+)/)[0] + "\".")});
  }
  const comments_arr = blocks.filter(blk => blk.match(comment_re));
  var files_arr = blocks.filter(blk => !blk.match(comment_re));
  const seq_comments_arr = contents.match(seq_comments_re); //This should be empty.
  if(Array.isArray(seq_comments_arr) && seq_comments_arr.length){
    seq_comments_arr.forEach( item => {errlist.push("Two comments cannot be sequential. Near \"" + item.split(/\n([\s\S]+)/)[0] + "\".")});
  }
  const bad_files_arr = files_arr.filter(file => !file.match(filename_validator_re));
  if(Array.isArray(bad_files_arr) && bad_files_arr.length){
    bad_files_arr.forEach( item => {errlist.push("Bad filename. Near \"" + item.split(/\n([\s\S]+)/)[0] + "\".")});
  }
  files_arr = files_arr.filter(file => file.match(filename_validator_re));
  var results = {};
  var badEntries = [];
  for (var idx = 0; idx < files_arr.length; ++idx) {
      var parts = files_arr[idx].split(/\n([\s\S]+)/);
      var path = parts[0].replace(header_re, "").replace(dequote_re, "").replace(unescape_re, "").trim();
      var body = parts[1];
      var isdir_bool = path[path.length -1] == "/";
      path = path.replace(/\/^/, "");
      if(isdir_bool && body.trim()){
        errlist.push("A directory cannot have contents. Near \"" + parts[0] + "\".");
      }else{
        gen_dir_arr = path.split("/");
        var pathx = "";
        for (var i = 0; i < gen_dir_arr.length-1; i++) {
          pathx += "/" + gen_dir_arr[i];
          if(pathx in results && results[pathx] != null){
            //Not a valid path.
            errlist.push("A file cannot be a directory. Near \"" + parts[0] + "\".");
          }else{
            results[pathx] = null;
          }
        }
        if(path in results){
          if(results[path] == null){
            errlist.push("A directory cannot be a file. Near \"" + parts[0] + "\".");
          }else{
            errlist.push("File already exists. Near \"" + parts[0] + "\".");
          }
        }else{
          results[path] = body.trim();
        }
      }
  }
  return [results, errlist];
}

module.exports = parse_hrx;
