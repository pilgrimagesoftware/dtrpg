## 1. Read Button Hint

- [ ] 1.1 Replace the plain "download this item first" tooltip with `gpui_component::hover_card::HoverCard`
- [ ] 1.2 Iterate on color/size interactively until it reads as a secondary hint, not primary text

## 2. Activity Button Tooltip

- [ ] 2.1 Replace the flat `activity_tooltip` string with a `HoverCard` showing in-progress and completed
  counts as separate lines/segments

## 3. Build and Verify

- [ ] 3.1 Run `cargo check --workspace`
- [ ] 3.2 Run `cargo clippy --all-targets --all-features -- -D warnings`
- [ ] 3.3 Manually verify the read-button hint's visual treatment
- [ ] 3.4 Manually verify the activity tooltip's structured layout
- [ ] 3.5 Manually verify unrelated simple tooltips are unaffected
