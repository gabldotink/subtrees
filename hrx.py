import re
input_expr = """<===> file1
This file doesn't have a trailng newline.
<===> file2
Neither does this one."""

#So this is kinda hacky buuut it mostly works. I'll work a bit more on it later...
lines = input_expr.splitlines()
#We kinda have to assume the first line is a header.
if len(lines) > 0:
    firstLine = lines[0]
    #A little thing is that the first header sentinel is **the** header sentinel.
    p = re.compile('<=+>')
    sentinel = p.match(firstLine).group()
    #Alright, let's strip comments.
    commentRegex = re.compile("(^|\n)" + sentinel + '\n[\s\S]*?((?=' + sentinel + ')|$)')
    input_expr = re.sub(commentRegex, "", input_expr)
    print(input_expr)
    #Now, build a regex that matches **all** first lines.
    headerLine = re.compile("(^|\n)" + sentinel + " +[^\u0000-\u001F\u007F\u003A\u005C\u000A]+")
    #Neat. Check it out. This'll tell me the boundaries of the objects.
    matches = list(re.finditer(headerLine,input_expr))
    results = {}
    for i in range(len(matches)):
        start = matches[i].end()
        end = len(input_expr)
        if(i+1 <= len(matches)-1):
            end = matches[i+1].start()
        fname = matches[i].group().replace(sentinel, "").strip()
        fcont = input_expr[start:end].strip('\n')
        content = {"isDirectory": fname.endswith("/"), "fileContents": fcont}

        results[matches[i].group().replace(sentinel, "").strip()] = content
    print(results)
else:
    print('ERR: No Input.')
