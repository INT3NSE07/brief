# mv

> Move or rename files and directories.

- Move files in arbitrary locations:

`mv {{source}} {{target}}`

- Do not prompt for confirmation before overwriting existing files:

`mv -f {{source}} {{target}}`

- Do not prompt for confirmation before overwriting existing files but write to standard error before overriding:

`mv -fi {{source}} {{target}}`

- Move files in verbose mode, showing files after they are moved:

`mv -v {{source}} {{target}}`

- Don't overwrite an existing file:

`mv -n {{source}} {{target}}`

- Move all source arguments into target directory:

`mv -t {{source}} {{target}}`

- Move only when source file is newer than the target file:

`mv -u {{source}} {{target}}`
