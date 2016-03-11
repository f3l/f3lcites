# F3LCites #

This is a fun-project that provides a HTTP-Database back-end for the
soon-to-come `!cite`-function of [f3lbot][f3lbot]

## What is it's purpose? ##

F3LCites should store cites that are pushed via HTTP in a local Database, plus
be able to reply to  queries either random or with a specific result.

Proposed API:

 * add: Insert cite into DB
 * random: Get random cite from DB
 * query: Get cite by ID
 * (someday) search: Search for cite-IDs
 
## Security Considerations ##

This tool is especially thought to run _on the same host as f3lbot_, and shall
only be reachable locally. It is not intended to be reachable by web! (Yup, I
know, bad practice, but as it was said: this is a fun-project for internal
use, please adapt if necessary)

[f3lbot]: https://github.com/f3l/f3lbot/
