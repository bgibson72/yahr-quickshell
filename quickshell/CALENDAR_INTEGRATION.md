# System Info Widget - Calendar Integration

The System Info Widget includes a Calendar tab that can display events from iCal files.

## Setting up Calendar Integration

### Option 1: Manual iCal File

Place your `.ics` calendar file at:
```
~/.config/quickshell/calendar.ics
```

### Option 2: Google Calendar Sync

To sync with Google Calendar:

1. Open Google Calendar in your browser
2. Go to Settings → Settings for my calendars → [Your Calendar]
3. Scroll to "Integrate calendar"
4. Copy the "Secret address in iCal format" URL
5. Create a sync script:

```bash
#!/bin/bash
# ~/.config/quickshell/sync-calendar.sh

CALENDAR_URL="YOUR_ICAL_URL_HERE"
curl -s "$CALENDAR_URL" > ~/.config/quickshell/calendar.ics
```

6. Make it executable:
```bash
chmod +x ~/.config/quickshell/sync-calendar.sh
```

7. Add to crontab to sync periodically:
```bash
# Sync every hour
0 * * * * ~/.config/quickshell/sync-calendar.sh
```

### Option 3: Other Calendar Services

Most calendar services (Outlook, iCloud, etc.) provide iCal export URLs:

- **Outlook/Microsoft 365**: Calendar → Share → Publish → Get ICS link
- **iCloud**: Calendar settings → Public Calendar → Copy webcal:// URL (replace `webcal://` with `https://`)
- **Nextcloud/Owncloud**: Calendar → Share → Copy secret link

Use the same sync script approach as Google Calendar.

## Features

- View calendar month with navigation
- Event indicators on days with events
- Detailed event list for selected day
- Supports:
  - All-day events
  - Timed events with start/end times
  - Event descriptions
  - Multiple events per day

## iCal Format Support

The widget supports standard iCal/RFC 5545 format with these fields:

- `SUMMARY`: Event title
- `DESCRIPTION`: Event details  
- `DTSTART`: Event start date/time
- `DTEND`: Event end date/time

Time formats supported:
- `DTSTART:20260115T100000` - Specific time
- `DTSTART;VALUE=DATE:20260115` - All-day event
