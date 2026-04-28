<div align="center">
  <img alt="logo" width="120" src="https://github.com/user-attachments/assets/f994edf4-c4be-46d2-a946-47d728171ffd" />
  <h1>Annotate · Frosted</h1>
</div>

<p align="center">
  <strong>A macOS screen annotation tool — same battle-tested logic, restyled UI.</strong><br>
  <em>This is a UI-only fork of <a href="https://github.com/epilande/Annotate">epilande/Annotate</a>. All credit for the actual app goes to <a href="https://github.com/epilande">@epilande</a>.</em>
</p>

---

## ⚠️ Attribution

This repo is a **design fork** of [`epilande/Annotate`](https://github.com/epilande/Annotate) (MIT). Every feature, every keyboard shortcut, every drawing tool — all written by [@epilande](https://github.com/epilande) and contributors. The fork only restyles the picker popovers and the on-screen feedback toast to a frosted-HUD aesthetic.

If you want the real, maintained app, **use the upstream repo**:

> 👉 https://github.com/epilande/Annotate

This fork is a personal customization that may not stay in sync with upstream releases. The MIT license carries through unchanged — see [LICENSE](LICENSE).

## What's different here?

UI only. No features added, no features removed.

| | Upstream | This fork |
|---|---|---|
| Color picker popover | flat squares, plain bg | frosted HUD blur + rounded swatches + hover state |
| Line width picker popover | flat panel | frosted HUD blur, refined typography, rounded preview |
| Feedback toast | solid white/black panel | frosted HUD blur with subtle border |
| Drawing engine | unchanged | unchanged |
| Shortcuts | unchanged | unchanged |
| Settings | unchanged | unchanged |

If you submit issues or feature requests, please file them on the [upstream repo](https://github.com/epilande/Annotate/issues), not here.

## Original README

The full feature list, controls reference, and build instructions live in the upstream README:

> https://github.com/epilande/Annotate/blob/main/README.md

A condensed copy of the controls follows, but treat upstream as the source of truth.

### Controls (from upstream)

| Key | Action |
|---|---|
| `1`–`9` | Select color from palette |
| `P` / `A` / `L` / `H` / `R` / `O` / `T` / `S` / `E` | Switch tool (Pen / Arrow / Line / Highlighter / Rectangle / Circle / Text / Select / Eraser) |
| `B` | Toggle whiteboard / blackboard |
| `K` | Toggle cursor highlight |
| `[` / `]` | Adjust line width |
| `⌘ Z` / `⌘ ⇧ Z` | Undo / Redo |
| `⌘ K` | Clear |
| `Space` | Toggle Fade / Persist mode |
| Global hotkey | Toggle overlay (configurable in Settings) |

## Build

```bash
xcodegen generate
open Annotate.xcodeproj
```

Or use the upstream build instructions — they apply unchanged.

## License

MIT, identical to upstream. Original copyright belongs to @epilande and Annotate contributors. See [LICENSE](LICENSE).
