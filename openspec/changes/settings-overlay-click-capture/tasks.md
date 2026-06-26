## 1. Fix Backdrop Hit-Testing

- [x] 1.1 In `render_settings_panel` in `dtrpg-ui/src/ui/views/settings_view.rs`, locate the outermost backdrop `div()` (the one with `.absolute().inset_0().bg(backdrop)`)
- [x] 1.2 Add `.id("settings-backdrop")` to that `div` so gpui registers it in the hitbox tree
- [x] 1.3 Add `.occlude()` after `.id(...)` to set `HitboxBehavior::BlockMouse`, which prevents all pointer events and hover states from reaching elements behind the backdrop
- [x] 1.4 Run `cargo check -p dtrpg-ui` and confirm zero errors

## 2. Verification

- [ ] 2.1 Open the app and click the gear button to open the settings panel; confirm the panel appears
- [ ] 2.2 Click each tab (Account, Storage, File Openers) and confirm only the active section changes — no catalog entry is selected and the detail panel does not open
- [ ] 2.3 Click the backdrop area outside the modal card and confirm the panel remains open and no catalog/sidebar action fires
- [ ] 2.4 Click the × close button and confirm the panel closes; then click catalog entries and confirm normal selection behavior resumes
- [ ] 2.5 Move the mouse over the open settings panel and confirm no catalog rows show hover highlights in the area behind the panel

