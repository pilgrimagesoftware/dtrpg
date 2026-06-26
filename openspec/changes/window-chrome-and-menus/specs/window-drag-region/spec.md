## ADDED Requirements

### Requirement: The window is movable by dragging the toolbar area
The system SHALL initiate a window move when the user presses and holds the primary mouse button within the toolbar row (the 53 px bar above the catalog).  Dragging while holding SHALL reposition the window in real time.  Releasing the mouse button SHALL complete the move.

#### Scenario: User drags the toolbar
- **WHEN** the user presses the left mouse button on an empty area of the toolbar row and begins moving the mouse
- **THEN** the window follows the mouse cursor until the button is released

#### Scenario: Drag does not fire on interactive toolbar controls
- **WHEN** the user presses the left mouse button on a button, dropdown, or text input within the toolbar
- **THEN** that control receives the event normally and no window move is initiated

### Requirement: The transparent title bar area above the toolbar is also draggable
The system SHALL make the transparent title bar region (the area between the window edge and the top of the toolbar) behave as a drag region, consistent with standard macOS window behavior.

#### Scenario: User drags via the title bar strip
- **WHEN** the user presses and drags in the transparent title bar strip at the top of the window
- **THEN** the window moves exactly as if dragged from the toolbar

### Requirement: Double-clicking the drag region zooms/unzooms the window
The system SHALL pass double-click events on the drag region to the OS so that the platform default behavior (zoom on macOS) is triggered.

#### Scenario: Double-click on toolbar drag region
- **WHEN** the user double-clicks on the empty area of the toolbar row
- **THEN** the window toggles between its normal size and the zoomed (maximized) state per the macOS system setting
