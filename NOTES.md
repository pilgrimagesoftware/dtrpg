# Notes

A place to keep track of things to tell the robot when limits are reached

- Update catalog automatic load logic
  - Load if local cache is empty
  - Load if last load was more than 1 week ago
  - Load if local cache count is different from remote count
- "Window" menu 
  - Show activity
  - Show alert history
- Account view in settings and Avatar menu *still* do not show user info
- Detail view close button does not show up
- Implement Alert history view
- Localizations missing:
  - "Collections" - section title 
  - "Collection" - catalog title 
  - "X items" - catalog item count
  - Pagination labels
  - "Search..." - search bar placeholder
  - "X titles" - sidebar text at bottom
  - Autofill, dictation, emoji menu items
  - "Updated <date>" label in detail view
- The page size control is missing from the pagination area
- Catalog items bleed off the right edge of the area instead of it reformatting to fit everything horizontally
- App should create the download path if it doesn't exist
- What is this "pre-existing docset failure" that is always mentioned?
- Add a "Refresh thumbnails" item to the Catalog menu
- Add a "Refresh thumbnail" button to the detail view
- Move the bottom left corner of the activity view up and to the right just a bit
- The "format" data in the detail view shows a filename and not a format type: fix the API -> model mapping?
- Fix the display of the updated date/time in the detail view
- Remove the "status" data in the detail view and replace it with an icon next to the item title
- Replace the large "Read" and "Download" buttons with icon buttons (and tooltips)
- Add a "clear cache" item to the settings view in a new "Advanced" section
- Add an About dialog from the application menu 
- Add an "About" section to the settings view
