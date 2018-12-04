# HRX.py
A lightweight implementation of the HRX spec in Python.

This implementation is incredibly hacky and relies very heavily on regexes. The upside to this is that it's treating the input as pure text, as opposed to trying to interpret the contents of files. This greatly improves speed over a parser that tries to parse the file contents
