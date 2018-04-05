# date

> Set or display the system date.

- Display the current date using the default locale's format:

`date +"%c"`

- Display the current date in UTC and ISO 8601 format:

`date -u +"%Y-%m-%dT%H:%M:%SZ"`

- Display the current date as a Unix timestamp (seconds since the Unix epoch):

`date +%s`

- Display a specific date (represented as a Unix timestamp) using the default format:

`date -d @1473305798`

- Display the date described by the string:

`date -d '{{String}}'`

- Display abbreviated Weekday name:

`date +%a`

- Display complete Weekday name:

`date +%A`

- Display abbreviated month name:

`date +%b`

- Display complete month name:

`date +%B`

- Display the current century:

`date +%C`

- Display numerical month:

`date +%m`

- Display numerical Day of the Week:

`date +%u`
