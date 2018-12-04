import re
def merge_hrx(input_files):

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

    # Compute sentinel length.
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
