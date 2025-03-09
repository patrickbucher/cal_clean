# Calendar Cleanup

Cleans up a folder containing iCalendar (`.ics`) files by deleting files that
only contain calendar events older than a given date.

## Usage

To delete all `.ics` files in `my-icalendar-folder/` that are older than the
first of December 2023:

    ./cleanup.rb my-icalendar-folder/ 2023-12-01