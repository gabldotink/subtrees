import re
import sys
from enum import Enum

class ParseError(Enum):
    ERR_MALFORMED_INPUT = 1
    ERR_SEQUENTIAL_COMMENTS = 2
    ERR_BAD_FILE_ENTRY = 3
    ERR_DIRECTORY_HAS_CONTENTS = 4
    ERR_DUPLICATE_FILE = 5
    ERR_TYPE_MISMATCH = 6

def parse(input_expr):
    error_list = []
    #Split into blocks (Comments, Files, etc.)
    blocks_re = re.compile(r'((<=+>)(( |\n)(("(?:[^"\\]|\\[^\u0000-\u001F\u007F\u003A\u005C\u000A])*")|[^\u0000-\u001F\u007F\u003A\u005C\u000A]*)(?=\n)?[\S\s]+?(?=\2|$)))')
    blocks_lst = list(blocks_re.finditer(input_expr))
    #Try to clean this up.
    error_list += [{'type': ParseError.ERR_MALFORMED_INPUT, 'match': i} for i in "\n".join(blocks_re.sub("\u0001", input_expr).split("\u0001")).strip().split("\n") if i]
    #Split comments into their own list away from files.
    comment_re = re.compile(r'^<=+>\n')
    comment_lst = [i for i in blocks_lst if comment_re.match(i.group())]
    file_lst = [i for i in blocks_lst if not comment_re.match(i.group())]
    #Verify comments aren't sequential.
    seq_comments_re = re.compile(r'^(<=+>\n.*\n+){2,}')
    seq_comments_lst = list(seq_comments_re.finditer(input_expr))
    #seq_comments_lst will have any matches where there's two or more comments. If it's > 0 it should throw an error.
    #print(len(seq_comments_lst))
    error_list += [{'type': ParseError.ERR_SEQUENTIAL_COMMENTS, 'match':i} for i in seq_comments_lst]
    #Validate filenames
    filename_re = re.compile(r'^<=+> "?(\.?[^\u0000-\u001F\u007F\u003A\u005C\u000A\u002F\u002E])((?!\/\/|\/\.{1,2}\/)[^\u0000-\u001F\u007F\u003A\u005C\u000A"]|\\")*"?\n')
    valid_files_lst = [fl for fl in file_lst if filename_re.match(fl.group())]
    invalid_files_lst = [fl for fl in file_lst if not filename_re.match(fl.group())]
    #invalid_files_lst will have any matches where there's an invalid file entry. If it's > 0 it should throw an error.
    #print(len(invalid_files_lst))
    error_list += [{'type': ParseError.ERR_BAD_FILE_ENTRY, 'match':i} for i in invalid_files_lst]
    #Generate a result list.
    header_re = re.compile(r'^<=+> ')
    dequote_re = re.compile(r'(^"|"$)')
    unescape_re = re.compile(r'\\(?=")')
    result_dict = {}
    for entry in valid_files_lst:
        #Strip the first line off, it has information we need.
        #Also remove the header character, and de-escape quotes, remove surrounding quotes as well.
        entry_str = entry.group()
        entry_list = entry_str.split('\n', 1)
        path_str = unescape_re.sub("", dequote_re.sub("", header_re.sub("", entry_list[0]))).strip()
        isdir_bool = path_str.endswith("/")
        path_str = path_str.rstrip('/')
        content_str = entry_list[1]
        if isdir_bool and not (content_str.isspace() or not content_str):
            #the content is invalid for a directory. Chuck an error.
            error_list.append({'type': ParseError.ERR_DIRECTORY_HAS_CONTENTS, 'match':entry})
        else:
            if path_str in result_dict:
                error_list.append({'type': ParseError.ERR_DUPLICATE_FILE, 'match':entry})
            else:
                result_dict[path_str] = {'path' : path_str, 'is_directory': isdir_bool, 'content' : content_str.strip()}

    #clean up the error list
    error_list = [i for i in error_list if i != []]
    return (result_dict, error_list)


def print_errors(error_list):
    for error_dict in error_list:
        if error_dict['type'] is ParseError.ERR_MALFORMED_INPUT:
            print(str(error_dict['type']) + " near \"" + error_dict['match'] + "\".")
        else:
            print(str(error_dict['type']) + " near \"" + error_dict['match'].group().split('\n',1)[0] + "\".")
