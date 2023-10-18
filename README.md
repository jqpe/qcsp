# qcsp

Quick Content Security Policy source hashes, because typing is painful.

## Features

- [x] Multiple input files
- [x] Supports all CSP hashing algorithms
- [x] No platform dependencies  

Instead of this:

```sh
result=$(cat ./sample.txt | openssl sha256 -binary | openssl base64)
echo "'sha256-$result:'"
```

You write this:
```sh
qcsp ./sample.txt
```

## Recipes

### Use a different algorithm
```sh
# sha 384
qcsp ./sample.txt -asha384
# sha 512
qcsp ./sample.txt -asha512
```