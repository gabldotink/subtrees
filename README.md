# HRX.js
An implementation of the [HRX spec](https://github.com/google/hrx) in JavaScript for NodeJS.

## Compatibility Notes
This uses negative lookbehinds in regular expressions so you have to use a relatively recent version of NodeJS.

## Usage
The only method exposed by `hrx.js` is `parse_hrx` at top-level.

```
const parse_hrx = require('./hrx.js');
```

### `parse_hrx(contents)`
This takes in a string containing the contents of an appropriate file, and returns an array.

```
const [hrx_parsed, errs] = parse_hrx(contents);
```

The `errs` entry contains an array of errors encountered while parsing.

The `hrx_parsed` entry is a JSON object that is appropriate for consumption with [MemFS](https://github.com/streamich/memfs).

## Notes
The difference between this version and the Python version is that the array of errors is just a set of strings that describe the fault. You should keep in mind to check the length of the error result.
