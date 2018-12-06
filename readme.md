# HRX.py
A lightweight implementation of the HRX ([google/hrx](https://github.com/google/hrx)) spec in Python.

This implementation is incredibly hacky and relies very heavily on regexes. The upside to this is that it's treating the input as pure text, as opposed to trying to interpret the contents of files. This greatly improves speed over a parser that tries to parse the file contents. Designing a parser that tries to make sense of sub-files may result in poor performance if the subfiles look or behave like the file being operated on.

## Usage
### Parse
Parse will parse a file in this format, and return a tuple that contains the parser's attempt, as well as a list of errors encountered.

```
# file_contents_str - A string representing the entire document to process.
(result_dict, error_list) = hrx.parse(file_contents_str)
# result_dict - A dictionary with entries at their path locations as keys.
# error_list - A list of errors generated during parsing.
```

### Printing Errors
```
# error_list - A list of errors generated during parsing.
hrx.print_errors(error_list)
# Prints any errors encountered during parsing.
```

The parser is supposed to attempt the file through to the end, reporting all errors encountered in a error list.


## Documentation on Types and Formats
### Error Format
```
{
  'type': parse_error,
  'match': match_hint_str
}
```

The field `type` will contain a value from the `ParseError` enum. It indicates what's gone wrong. See the section on ParseError below.
The field `match` will contain a hint near the entry that is causing problems.

### Result Format
```
file_path_str : {
  'content': file_contents_str,
  'is_autogen': is_autogen_bool,
  'is_directory': is_directory_bool,
  'path': file_path_str
}
```

The field `content` will contain the contents of the file. It will be blank if this is a directory entry.
The field `is_autogen` will indicate if the entry was automatically generated when implicitly creating directories. This happens if you specify a path of a file in a directory that does not exist. The parser will generate directories as needed.
The field `is_directory` will indicate if the entry is a directory.
The field `path` contains the same contents as the key used to access the entry in the dictionary.


### ParseError Types
```
ERR_MALFORMED_INPUT = 1
ERR_SEQUENTIAL_COMMENTS = 2
ERR_BAD_FILE_ENTRY = 3
ERR_DIRECTORY_HAS_CONTENTS = 4
ERR_DUPLICATE_FILE = 5
ERR_FILE_IS_NOT_DIR = 6
ERR_DIR_IS_NOT_FILE = 7
```

#### ERR_MALFORMED_INPUT
A parse error was encountered with malformed input. An entry could not be parsed for one reason or another, potentially due to an incorrect format for the header of the entry.

Example
```
===> some/invalid/header
Invalid entry header.
```

#### ERR_SEQUENTIAL_COMMENTS
Sequential comments are not permitted and will throw an error. Try to coalesce comments into one block as needed.

Example
```
<===>
Comment the First!

<===>
Comment the Second! This is not valid!
```

#### ERR_BAD_FILE_ENTRY
A file entry or path has illegal characters in its name. A file cannot contain the following characters or sequences.
```
[\u0000-\u001F\u007F]
/
:
\
^..
^.
/../
/./
^/
```

Example
```
<===> an/invalid/../path
this path is invalid since it contains /../
```

#### ERR_DIRECTORY_HAS_CONTENTS
A directory entry cannot contain contents in the definition file. Its body must be blank.

Example
```
<===> some/directory/
a directory cannot have contents
```

#### ERR_DUPLICATE_FILE
The file specified exists already and the attempt was not written. The first entry to appear has been written and any further were ignored.

Example
```
<===> some/file
some file contents that will show in the result.

<===> some/file
this will not be included in the result.
```

#### ERR_FILE_IS_NOT_DIR
A file is not a directory. An entry already exists along the path that is designated as a file, and thus cannot have files inside it.

Example
```
<===> some/file
some file contents

<===> some/file/again
this file is invalid since some/file is a file not a directory.
```

#### ERR_DIR_IS_NOT_FILE
A directory is not a file. An entry already exists at this same path that is a directory and cannot be converted to a file.

Example
```
<===> dir/something/

<===> dir/something
this path is a directory and cannot be a file.
```
