__copyright__ = """

    Copyright 2020 Rebecca Pruim

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

"""
__license__ = "Apache 2.0"

import re
from enum import Enum

class ParseError(Enum):
    ERR_MALFORMED_INPUT = 1
    ERR_SEQUENTIAL_COMMENTS = 2
    ERR_BAD_FILE_ENTRY = 3
    ERR_DIRECTORY_HAS_CONTENTS = 4
    ERR_DUPLICATE_FILE = 5
    ERR_FILE_IS_NOT_DIR = 6
    ERR_DIR_IS_NOT_FILE = 7

def parse(file_contents_str):
    error_list = []
    #Split into blocks (Comments, Files, etc.)
    blocks_re = re.compile(r'((<=+>)(( |\n)([^\u0000-\u001F\u007F\u003A\u005C\u000A]*)(?=\n)?[\S\s]+?(?=\2|$)))')
    blocks_lst = list(blocks_re.finditer(file_contents_str))
    #Try to clean this up.
    error_list += [{'type': ParseError.ERR_MALFORMED_INPUT, 'match': i} for i in "\n".join(blocks_re.sub("\u0001", file_contents_str).split("\u0001")).strip().split("\n") if i]
    #Split comments into their own list away from files.
    comment_re = re.compile(r'^<=+>\n')
    comment_lst = [i for i in blocks_lst if comment_re.match(i.group())]
    file_lst = [i for i in blocks_lst if not comment_re.match(i.group())]
    #Verify comments aren't sequential.
    seq_comments_re = re.compile(r'^(<=+>\n.*\n+){2,}')
    seq_comments_lst = list(seq_comments_re.finditer(file_contents_str))
    #seq_comments_lst will have any matches where there's two or more comments. If it's > 0 it should throw an error.
    #print(len(seq_comments_lst))
    error_list += [{'type': ParseError.ERR_SEQUENTIAL_COMMENTS, 'match':i.group().split('\n',1)[0]} for i in seq_comments_lst]
    #Validate filenames
    filename_re = re.compile(r'^<=+> (\.?[^\u0000-\u001F\u007F\u003A\u005C\u000A\u002F\u002E])((?!\/\/|\/\.{1,2}\/)[^\u0000-\u001F\u007F\u003A\u005C\u000A])*\n')
    valid_files_lst = [fl for fl in file_lst if filename_re.match(fl.group())]
    invalid_files_lst = [fl for fl in file_lst if not filename_re.match(fl.group())]
    #invalid_files_lst will have any matches where there's an invalid file entry. If it's > 0 it should throw an error.
    #print(len(invalid_files_lst))
    error_list += [{'type': ParseError.ERR_BAD_FILE_ENTRY, 'match':i.group().split('\n',1)[0]} for i in invalid_files_lst]
    #Generate a result list.
    header_re = re.compile(r'^<=+> ')
    result_dict = {}
    for entry in valid_files_lst:
        #Strip the first line off, it has information we need.
        #Also remove the header character, and de-escape quotes, remove surrounding quotes as well.
        entry_str = entry.group()
        entry_list = entry_str.split('\n', 1)
        path_str = header_re.sub("", entry_list[0]).strip()
        isdir_bool = path_str.endswith("/")
        path_str = path_str.rstrip('/')
        content_str = entry_list[1]
        if isdir_bool and not (content_str.isspace() or not content_str):
            #the content is invalid for a directory. Chuck an error.
            error_list.append({'type': ParseError.ERR_DIRECTORY_HAS_CONTENTS, 'match':entry.group().split('\n',1)[0]})
        else:
            #Iterate through each constituent path on the way to the final file.
            gen_dir_list = path_str.split("/")
            for i in range(len(gen_dir_list)-1):
                intermediate_dir_str = "/".join(gen_dir_list[0:i+1])
                if intermediate_dir_str in result_dict and not result_dict[intermediate_dir_str]['is_directory']:
                    error_list.append({'type': ParseError.ERR_FILE_IS_NOT_DIR, 'match':entry.group().split('\n',1)[0]})
                elif intermediate_dir_str not in result_dict:
                    result_dict[intermediate_dir_str] = {'path' : intermediate_dir_str, 'is_directory': True, 'content' : '', 'is_autogen': True}
            if path_str in result_dict:
                if result_dict[path_str]['is_directory']:
                    error_list.append({'type': ParseError.ERR_DIR_IS_NOT_FILE, 'match':entry.group().split('\n',1)[0]})
                else:
                    error_list.append({'type': ParseError.ERR_DUPLICATE_FILE, 'match':entry.group().split('\n',1)[0]})
            else:
                result_dict[path_str] = {'path' : path_str, 'is_directory': isdir_bool, 'content' : content_str.strip(), 'is_autogen': False}

    #clean up the error list
    error_list = [i for i in error_list if i != []]
    return (result_dict, error_list)


def print_errors(error_list):
    for error_dict in error_list:
        print(str(error_dict['type']) + " near \"" + error_dict['match'] + "\".")
