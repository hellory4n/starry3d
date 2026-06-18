# Tags

Tags are 4 character strings seen everywhere in Starry. But why?

## Why?

Tags are used to uniquely identify things, such as material properties. There are many ways of doing that:
- enum: can't be extended by other developers
- number: easy to get conflicting numbers
- string: slower and requires memory allocations
- UUID: not human readable

Tags solve this by being a very small string. Tags are always the same size (same size as a 32-bit integer), making it smaller, easier to manage, and faster.

## Can I use Unicode?

No.

Technically it's possible, but tags are always 4 bytes, so it probably won't fit. Stick with ASCII.
