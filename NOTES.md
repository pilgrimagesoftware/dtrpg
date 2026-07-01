# Notes

A place to keep track of things to tell the robot when limits are reached

- Put counts for collections and publishers next to their section titles
- Update catalog automatic load logic
  - Load if local cache is empty
  - Load if last load was more than 1 week ago
  - Load if local cache count is different from remote count
- Add "Catalog" menu 
  - Add collection
  - Reload 
- "Window" menu 
  - Show activity
  - Show alert history
- Count value for catalog title
  - Total count of items in catalog when not filtered
  - Filter count / total count when filtered
- Context menu for collections
  - Reload
  - Delete
- Collections still don't load
- Remove button for file openers item does not work
- Account view in settings and Avatar menu *still* do not show user info
- Pagination controls should also have First and Last buttons
- Remove resizing controls on the catalog view; just pin it to the left sidebar and right window edge
- Detail view close button does not show up
- Collections and Publishers sections do not remember their collapsed state
- Triggering a reload from the menu doubles the catalog content
- The count at the top should be below content title
  - Format: "[X publisher items,] X total items (X filtered)"
  - "publisher items" only appears when publisher is selected
  - "filtered" only appears when filtered by search term
- Add collection button (+) in collections section does not work
- Get rid of the size control for the content area
- Detail view contents do not scroll
- Collections and Publishers sections each need their own search widget
  - Just a magnifying glass icon, when clicked expands to a full-width search bar
  - Filter contents of section, do not persist across sessions
