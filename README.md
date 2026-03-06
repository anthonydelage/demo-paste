# Demo Paste

Hotkey-driven demo pasting on macOS. Select a demo flow, then type pre-written script steps into any focused text field with a single keystroke.

## What this does

- Press `right_option + N` to activate one of up to five demo scripts.
- Press `ctrl + alt + cmd + M` to type step M of the active demo into the focused field.
- Steps are plain text files. Adding a new demo requires zero code changes.
- Text is inserted via keyboard events, not the clipboard.

## Stack

- [Karabiner-Elements](https://karabiner-elements.pqrs.org/) remaps `right_option + 0..5` to F13-F18 (Hammerspoon cannot distinguish left/right modifiers).
- [Hammerspoon](https://www.hammerspoon.org/) binds F-keys for demo selection and `ctrl+alt+cmd+1..9` for step pasting.

## Repository layout

```
configs/
  karabiner.sample.json              Karabiner rule to merge into your profile.
  hammerspoon/
    init.sample.lua                  Minimal init that loads demo-paste.
    lib/
      utils.lua                      Shared helpers (notify, readFile, typeText).
      demo-paste.lua                 Demo paste module.
scripts/
  1-example/
    1.txt                            Placeholder step 1.
    2.txt                            Placeholder step 2.
```

## Prerequisites

```bash
brew install --cask hammerspoon karabiner-elements
```

## Setup

### 1) Create demo scripts

Demo scripts live in a directory outside this repo. The default path is:

```
~/Coveo/demo-content/scripts/
```

Create numbered subdirectories with numbered `.txt` files:

```
~/Coveo/demo-content/scripts/
  1-intro/
    1.txt
    2.txt
    3.txt
  2-advanced/
    1.txt
    2.txt
```

The directory prefix (`1`, `2`, ...) maps to hotkey slot 1-5. Each `.txt` file holds the exact text that will be typed for that step.

To change the scripts directory, edit `SCRIPTS_DIR` in `lib/demo-paste.lua`.

### 2) Install Hammerspoon config

Copy the sample configs into place:

```bash
mkdir -p "$HOME/.hammerspoon/lib"
cp configs/hammerspoon/init.sample.lua "$HOME/.hammerspoon/init.lua"
cp configs/hammerspoon/lib/utils.lua "$HOME/.hammerspoon/lib/utils.lua"
cp configs/hammerspoon/lib/demo-paste.lua "$HOME/.hammerspoon/lib/demo-paste.lua"
```

If you already have a Hammerspoon config, add `require("lib.demo-paste")` to your existing `init.lua` and copy only the `lib/` files.

### 3) Install Karabiner rule

If you do not already maintain a custom Karabiner profile, create the config directory and add the rule manually.

If you already have a Karabiner setup, merge the rule from `configs/karabiner.sample.json` into your existing profile under:

```
profiles[].complex_modifications.rules[]
```

Do not overwrite unrelated existing rules.

### 4) Reload apps

- Karabiner auto-reloads when `karabiner.json` is saved.
- Hammerspoon: use menu bar -> `Reload Config`.

## macOS permissions

Grant these in System Settings -> Privacy & Security:

- **Accessibility**: Hammerspoon (required for keystroke injection).
- **Input Monitoring**: Hammerspoon (recommended).

Without Accessibility permission, hotkeys and text insertion will fail silently. If permissions stop working after a macOS update, toggle them off and on, then restart Hammerspoon.

## Usage

### Hotkey reference

| Action | Keys | What happens |
|---|---|---|
| Deactivate demo | `right_option + 0` | Clears active demo. Step keys do nothing. |
| Activate demo N | `right_option + 1..5` | Selects demo N. Shows notification. |
| Paste step M | `ctrl + alt + cmd + 1..9` | Types step M of the active demo. |

### Adding a new demo

1. Create a directory: `~/Coveo/demo-content/scripts/3-my-demo/`
2. Add step files: `1.txt`, `2.txt`, etc.
3. Press `right_option + 3` to activate it. No reload needed.

Demo directories are rescanned each time you activate a slot.

## Troubleshooting

- **Hotkey not firing**: Open Karabiner-Elements and verify the rule is enabled in the active profile.
- **No text inserted**: Check Hammerspoon Accessibility permission. Secure Input (enabled by some password fields and apps) blocks keystroke injection.
- **Wrong step text**: Verify file numbering matches the expected step. Files must be named `1.txt` through `9.txt`.
- **Extra characters or missing text**: `hs.eventtap.keyStrokes` types each character as a key event. Very long texts may drop characters at high speed. Keep steps to a few sentences.

## Public repo safety checklist

Before publishing:

```bash
git ls-files
git status
```

Confirm only expected files are tracked (`README.md`, `LICENSE`, `.gitignore`, `configs/`, `scripts/1-example/`).

Demo content with real customer or product data should remain outside this repo in your local scripts directory.
