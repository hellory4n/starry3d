# Tags

Tags are 8 or 4 character strings seen everywhere in Starry. But why?

## Why?

Tags are used to uniquely identify things, such as material properties. There are many ways of doing that:
- enum: can't be extended by other developers
- number: easy to get conflicting numbers
- string: slower and requires memory allocations
- UUID: not human readable

Tags solve this by being a very small string. Tags are always the same size (same size as a 32 or 64 bit integer), making it smaller, easier to manage, and faster.

Note that tags are assigned by humans. If you need random IDs, it's better to use a random number or UUID.

## What size should I use?

`Tag32` can be quite cryptic, so you should use `Tag64` unless your space is limited.

## Can I use Unicode?

No.
