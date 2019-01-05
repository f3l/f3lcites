# F3LCites #

[![Build Status](https://travis-ci.org/f3l/f3lcites.svg?branch=master)](https://travis-ci.org/f3l/f3lcites)
[![codecov](https://codecov.io/gh/f3l/f3lcites/branch/master/graph/badge.svg)](https://codecov.io/gh/f3l/f3lcites)

This is a fun-project that provides a HTTP-Database back-end for the
`!cite`-function of [f3lbot][f3lbot]

## What is it's purpose? ##

F3LCites provides a Web-Interface to the F3LCites Database (inside a redis
instance) and allows
to

 * Add Quotes
 * Get a random quote
 * List existing quotes

## Compilation ##

For a "release"-type binary with freshly generated CSS file, simply run

```
dub run --compiler=ldc2 -a=x86_64 -b=debug -c=generateCss
```

## Security Considerations ##

This tool is especially thought to run _on the same host as f3lbot_, and shall
only be reachable locally. It is not intended to be reachable by web! (Yup, I
know, bad practice, but as it was said: this is a fun-project for internal
use, please adapt if necessary)

## Configuration ##

Configure the port and addresses to bind to using your local vibe.d-config:

```
{
    "port": "80",
    "address": ["127.0.0.1", "192.168.0.100"]
}
```

It is strongly advised to use a reverse-proxy like nginx for user
authentication. Provide a location `/cites/assets` for static files (css!).

[f3lbot]: https://github.com/f3l/f3lbot/
