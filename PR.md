# Fix snackbars on Flutter 3.47 and harden the save sheet's "New playlist" flow

## Problem

- **Every `Get.snackbar` threw "No Overlay widget found".** Flutter 3.47's `Overlay.of` only resolves from inside an overlay entry, and get 4.7.2 looked it up from above one. This broke the "Playlist created", "Saved to playlist" and "Removed from playlist" messages.
- **"New playlist" relied on timing.** The save sheet popped itself, then opened the next sheet with its own context, which only worked while the closing animation kept that context alive. The "saved" confirmation after that also lost the full-player routing.

## Solution

- Upgraded `get` to 4.7.3 (constraint `^4.7.3`), which inserts snackbars into the navigator's overlay directly.
- The save sheet captures its `NavigatorState` before popping, opens "New playlist" from it, and passes it to `_snack`, so the confirmation still shows inside the full player when opened there.

## Testing

- [x] New widget test: "New playlist" creates the playlist, saves the item, and shows both confirmations (fails on get 4.7.2)
- [x] `flutter test` passes (18 tests)
- [ ] On device: save → New playlist → Create shows "Playlist created" then "Saved to playlist"
- [ ] Same from the full player: confirmations appear on top of the player
