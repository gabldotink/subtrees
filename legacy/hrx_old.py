import re
import sys

def parse(input_expr):
    lines = input_expr.splitlines()
    #We kinda have to assume the first line is a header.
    results = {}
    invalidPaths = re.compile('(\/\.\.\/|^\/|^\.\.\/|\/\/)')
    if len(lines) > 0:
        firstLine = lines[0]
        #A little thing is that the first header sentinel is **the** header sentinel.
        p = re.compile('<=+>')
        if p.match(firstLine) is None:
            print("ERR: Valid boundary not found on first line.")
            return 1
        sentinel = p.match(firstLine).group()
        #Alright, let's strip comments.
        commentRegex = re.compile(sentinel + '\n[\s\S]*?\n')
        tooManyComments = re.compile('(' + sentinel + '\n[^<]*?){2,}')
        lotsacomments = list(re.finditer(tooManyComments,input_expr))
        if len(lotsacomments) > 0:
            print("ERR: Consecutive comments near " + lotsacomments[0].group())
            return 6
        input_expr = re.sub(commentRegex, "", input_expr)
        #Now, build a regex that matches **all** first lines.
        headerLine = re.compile("(^|\n)" + sentinel + " +[^\u0000-\u001F\u007F\u003A\u005C\u000A]+")
        #Neat. Check it out. This'll tell me the boundaries of the objects.
        matches = list(re.finditer(headerLine,input_expr))
        for i in range(len(matches)):
            start = matches[i].end()
            end = len(input_expr)
            if(i+1 <= len(matches)-1):
                end = matches[i+1].start()
            fname = matches[i].group().replace(sentinel, "").strip()
            fcont = input_expr[start:end].strip('\n')
            if fname.endswith("/") and fcont is not '':
                print("ERR: A directory cannot have content. (At definition of " + fname + ")")
                return 5

            if invalidPaths.search(fname) is not None:
                #Invalid path.
                print("ERR: A path cannot start with or contain './' or '../'. (At definition of " + fname + ")")
                return 4

            content = {"isDirectory": fname.endswith("/"), "fileContents": fcont}
            if fname in results or fname.strip('"') in results:
                print("ERR: Duplicate File. (At definition of " + fname + ")")
                return 2
            else:
                results[matches[i].group().replace(sentinel, "").strip()] = content
    else:
        print('ERR: No Input.')
        return 3

    return results


def pack(input_files):
    p = re.compile('<=+>')
    output = ""
    new_sent_len = 1
    # Compute sentinel length.
    for i in range(len(input_files)):
        file = open(input_files[i], "r")
        fcont = file.read()
        for match in p.finditer(fcont):
            sentinelLen = match.group().count('=')
            if sentinelLen > new_sent_len:
                new_sent_len = sentinelLen + 1

    for i in range(len(input_files)):
        sentinel = '<' + '='*new_sent_len + '> ' + input_files[i].replace('\\', '/') + "\n" #This makes windows happy.
        output += sentinel
        file = open(input_files[i], "r")
        output += file.read()
        output += "\n"

    return output.strip()

def merge(input_files):
    p = re.compile('<=+>')
    output = ""
    new_sent_len = 1
    # Compute sentinel length.
    for i in range(len(input_files)):
        file = open(input_files[i], "r")
        fcont = file.read()
        for match in p.finditer(fcont):
            sentinelLen = match.group().count('=')
            if sentinelLen > new_sent_len:
                new_sent_len = sentinelLen + 1

    newSentinel = '<' + '='*new_sent_len + '> '

    for i in range(len(input_files)):
        file = open(input_files[i], "r")
        fcont = file.read()
        fcont_fline = fcont.splitlines()[0]
        if p.match(fcont_fline) is None:
            print("ERR: Valid boundary not found on first line.")
            return 1
        sentinel = p.match(fcont_fline).group()
        fcont = fcont.replace(sentinel, newSentinel)

        output += fcont + "\n"

    return output.strip()
