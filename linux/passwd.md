# passwd

> Passwd is a tool used to change a user's password.

- Change the password of the current user:

`passwd {{new password}}`

- Change the password of the specified user:

`passwd {{username}} {{new password}}`

- Get the current status of the user:

`passwd -S`

- Lock the password of a user:

`passwd -l {{user}}`

- Unlock the password of a user:

`passwd -u {{user}}`

- Delete the password of a user:

`passwd -d {{user}}`

- Expire the password of a user:

`passwd -e {{user}}`

- Make passwords visible while typing:

`passwd --stdin {{user}}` 
