__copyright__ = """

    Copyright 2018 Rebecca Pruim

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

import pprint
import hrx
import sys

fname = sys.argv[1]
file = open(fname, "r")

(result,err) = hrx.parse(file.read())

print("==== Parser Attempt ====")
pp = pprint.PrettyPrinter(depth=6)
pp.pprint(result)
print("\n==== Parser Errors ====")
hrx2.print_errors(err)
