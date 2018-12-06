# HRX.py
A lightweight implementation of the HRX ([google/hrx](https://github.com/google/hrx)) spec in Python.

This implementation is incredibly hacky and relies very heavily on regexes. The upside to this is that it's treating the input as pure text, as opposed to trying to interpret the contents of files. This greatly improves speed over a parser that tries to parse the file contents. Designing a parser that tries to make sense of sub-files may result in poor performance if the subfiles look or behave like the file being operated on.

## Usage
### Careful! The following docs are for `hrx.py` not `hrx2.py`.
There exist three parts, `parse`, `pack`, and `merge`. Import `hrx` and use all of them, or import one from `hrx`.

### Parse
Parse will parse a file in this format, throwing errors as necessary. It's a bit more involved than the other two parts.

`hrx.parse(file_contents)`
Returns
`dict - A representation of the constituent files where their filenames are used as keys.`
```
'filename' : {
  'isDirectory' : bool,
  'fileContents' : string
}
```
### Pack
Pack will take a list of files that are in this format, and pack them into an archive. In theory this will work with any arbitrary file.

`hrx.pack(file_paths)`
Returns
`string - A packed representation of the input files`

### Merge
Merge is similar to Pack, but it merges a bunch of files into one single file, as opposed to retaining their filenames independently. Pass it a list of file paths.

`hrx.merge(file_paths)`
Returns
`string - A merged representation of the input files`

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
