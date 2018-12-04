import re
def create_sub_hrx(input_files):
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
