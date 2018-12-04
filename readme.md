# HRX.py
A lightweight implementation of the HRX ([google/hrx](https://github.com/google/hrx)) spec in Python.

This implementation is incredibly hacky and relies very heavily on regexes. The upside to this is that it's treating the input as pure text, as opposed to trying to interpret the contents of files. This greatly improves speed over a parser that tries to parse the file contents

## Behavior re: Test Files
### comment-only.hrx
```
{}
```

### comments.hrx
```
{
  'file1': {'isDirectory': False, 'fileContents': 'This is the contents of the file.'},
  'file2': {'isDirectory': False, 'fileContents': 'This is the contents of another file.'}
}
```

### complex-filenames.hrx
```
{
  '.dir/.../.file': {'isDirectory': False, 'fileContents': 'Filenames may contain dots, as long as they\'re not "." or "..".'},
  '~`!@#$%^&*()_-+= {}[]|;"\'<,>.?': {'isDirectory': False, 'fileContents': 'Filenames can contain all kinds of weird characters.'},
  '☃': {'isDirectory': False, 'fileContents': 'Non-ASCII Unicode names are allowed.'}
}
```

### directory.hrx
```
{
  'dir/': {'isDirectory': True, 'fileContents': ''},
  'dir/subdir/': {'isDirectory': True, 'fileContents': ''},
  'other/subdir/': {'isDirectory': True, 'fileContents': ''}
}
```

### empty-file.hrx
```
{
  'file1': {'isDirectory': False, 'fileContents': ''},
  'file2': {'isDirectory': False, 'fileContents': ''}
}
```

### files-in-directories.hrx
```
{
  'dir/file1': {'isDirectory': False, 'fileContents': 'This file is in a directory. Directories implicitly exist once there are any\nfiles in them.'},
  'path/to/file2': {'isDirectory': False, 'fileContents': 'This file is in a deeper directory.'}
}
```

### inline-boundary.hrx
```
{
  'file': {'isDirectory': False, 'fileContents': "This <===> doesn't count as a boundary because it's not on its own line."}
}
```

### nested.hrx
```
{
  'file1.hrx': {'isDirectory': False, 'fileContents': "<=====> nested-file1.hrx\nThis is a HRX file nested within a HRX file.\n\n<=====> nested-file2.hrx\nYou can tell it's not part of the outer file because the boundaries are longer."},
  'file2.hrx': {'isDirectory': False, 'fileContents': "<=> nested-file1.hrx\nInner files can also contain shorter boundaries...\n\n<=> nested-file2.hrx\n...as long as they don't contain the outer file's boundary."}
}
```

### no-trailing-newlines.hrx
```
{
  'file1': {'isDirectory': False, 'fileContents': "This file doesn't have a trailng newline."},
  'file2': {'isDirectory': False, 'fileContents': 'Neither does this one.'}
}
```

### quoted-filename.hrx
```
{
  '"path to/my file"': {'isDirectory': False, 'fileContents': "Filenames may contain spaces as long as they're quoted."},
  '"file"name"': {'isDirectory': False, 'fileContents': "Filenames may contain quotes as long as they're escaped."},
  'file"name': {'isDirectory': False, 'fileContents': 'Even unquoted filenames may contain escaped quotes.'}
}
```

### simple.hrx
```
{
  'input.scss': {'isDirectory': False, 'fileContents': 'ul {\n  margin-left: 1em;\n  li {\n    list-style-type: none;\n
}\n}'},
  'output.css': {'isDirectory': False, 'fileContents': 'ul {\n  margin-left: 1em;\n}\nul li {\n  list-style-type: none;\n}'}
}
```

### trailing-comment.hrx
```
{
  'file.hrx': {'isDirectory': False, 'fileContents': 'The contents of a file.'}
}
```

## Broken Files
I personally don't believe that the archive should necessarily be sanity-checked by the parser, so validating if a subfile is valid is out of the scope of the design. Take for example the restriction on a comment following another comment: The parser does support this, however it merely doesn't produce any output. I will be adding cases to handle these, but I don't feel like validating sub-archives is necessarily part of this, Sure, it'll throw an error if you try to operate on the sub-archive, however, validating everything within the file seems like it'd lead to feature creep. And further, dealing with invalid paths is expected to be handled by a further stage of the archive processor, all the current thing does is it reads in a file then produces a descriptor. 
