# UI Layout Revamp

- See gpui-components gallery demo

## Main window

- Title bar
  - horizontal separator between it and content area
  - Contents:
    - <title>
    - <padding>
    - Account button
      - avatar image
      - menu: user info, settings, sign out
- Content area
  - Collapsible left sidebar (Sheet?)
    - Default sections with counts 
    - Collections section (as it is now: item count, search controls, add button, collapsible)
    - Publishers section (as it is now: item count, search controls, collapsible)
  - Main area 
    - Tabs (dynamic segmented with more menu)
    - First tab (non-closable): catalog
      - <title> <padding> <search box> <sorting> <mode>
      - contents displayed according to mode, etc.; no pagination
      - any item single-clicked opens detail view as a Popover
      - any item double-clicked opens expanded detail view as a new tab with close button 
        - large thumbnail
        - attributes
        - file list if catalog item has multiple 
- Status bar
  - Contents:
    - Total item count of library with size
    - Divider
    - Current content area: "<title> - X items [, X items selected]"
    - <padding>
    - Theme picker 
      - hover shows current theme
      - click opens menu to choose theme
    - Activity indicator: Progress 
      - hover gives operation count: "X in progress, Y completed"
      - click opens detail panel/sheet/view/?
    - Notification indicator: bell icon with badge?
      - hover shows unread notification count
      - click opens notification panel/sheet/view/?
