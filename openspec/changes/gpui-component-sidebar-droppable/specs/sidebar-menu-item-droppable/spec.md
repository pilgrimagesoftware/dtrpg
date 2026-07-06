## ADDED Requirements

### Requirement: SidebarMenuItem supports drop-target behavior
`gpui-component`'s `SidebarMenuItem` SHALL expose a builder method (e.g. `droppable::<T>(style_fn,
on_drop_fn)`) that makes a rendered row a drop target for a payload type `T`, applying caller-supplied
hover styling while a compatible drag is over the row and invoking a caller-supplied callback on drop —
without requiring the caller to access `SidebarMenuItem`'s internal element construction.

#### Scenario: Hover styling while a compatible drag is over a droppable row
- **WHEN** a drag carrying a payload of type `T` is moved over a `SidebarMenuItem` configured with
  `.droppable::<T>(...)`
- **THEN** the row renders with the style the caller supplied to `droppable`

#### Scenario: Drop callback fires with the dragged payload
- **WHEN** a drag carrying a payload of type `T` is released over a `SidebarMenuItem` configured with
  `.droppable::<T>(...)`
- **THEN** the caller-supplied `on_drop` callback is invoked with a reference to the dragged payload

#### Scenario: Non-matching payload types are ignored
- **WHEN** a drag carrying a payload of a type other than `T` is released over a `SidebarMenuItem`
  configured with `.droppable::<T>(...)`
- **THEN** the row's `on_drop` callback for `T` does not fire and no hover styling is applied

### Requirement: dtrpg-app/rust's Collections section uses SidebarMenuItem
The Collections section in `dtrpg-app/rust`'s sidebar SHALL be built using
`gpui_component::sidebar::{SidebarMenu, SidebarMenuItem}` — the same components used by the smart-filter
and Publishers sections — rather than a hand-rolled row implementation, once `SidebarMenuItem` supports
`droppable`.

#### Scenario: Dragging a catalog item onto a collection still adds it as a member
- **WHEN** a user drags a catalog item onto a collection row in the sidebar
- **THEN** the item is added as a member of that collection, exactly as before this change (see
  `catalog-drag-drop-to-collection`), with no user-visible behavior difference

#### Scenario: Collections section styling matches other sidebar sections by construction
- **WHEN** the Collections section is rendered
- **THEN** its rows share `SidebarMenuItem`'s hover/active styling, spacing, and submenu indentation
  automatically (via `SidebarMenuItem` itself), rather than via a separately maintained duplicate
  implementation
