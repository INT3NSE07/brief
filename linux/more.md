# more

> Open a file for interactive reading, allowing scrolling and search (in forward direction only).

- Open a file:

`more {{source_file}}`

- Page down:

`<Space>`

- Search for a string (press `n` to go to the next match):

`/{{something}}`

- Exit:

`q`

- Squeeze multiple blank lines into one:

`more -s {{source_file}}`

- Use n number of lines as screen size:

`more -n {{source_file}}`

- Display each file from line number n:

`more +n {{source_file}}`

- Display file after the string occurs:

`more /string {{source_file}}`
