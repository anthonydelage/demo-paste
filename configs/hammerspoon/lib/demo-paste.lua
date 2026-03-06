-- =============================================================================
-- lib/demo-paste.lua — Scripted demo pasting
-- =============================================================================
-- Demo selection (via Karabiner: ropt+N -> F-key):
--   ropt+0 (F13)   Deactivate — no demo selected, step keys do nothing.
--   ropt+1 (F14)   Activate demo 1.
--   ropt+2 (F15)   Activate demo 2.
--   ropt+3 (F16)   Activate demo 3.
--   ropt+4 (F17)   Activate demo 4.
--   ropt+5 (F18)   Activate demo 5.
--
-- Step pasting (ctrl+alt+cmd+M):
--   ctrl+alt+cmd+1..9   Paste step M of the active demo.
--                        Deterministic: key M always pastes step M.
--
-- Demo scripts live in numbered directories:
--   ~/demo-scripts/N-<name>/1.txt .. 9.txt
--
-- The directory prefix N maps to demo slot N (max 5).
-- To add a new demo, create a new N-<name>/ directory with numbered .txt files.
-- =============================================================================

local utils = require("lib.utils")

local SCRIPTS_DIR  = utils.HOME .. "/demo-scripts"
local MAX_DEMOS    = 5
local MAX_STEPS    = 9
local MODS         = {"ctrl", "alt", "cmd"}

-- F-key mapping: slot 0 -> f13, slot 1 -> f14, ..., slot 5 -> f18 (contiguous)
local SLOT_FKEYS = {
  [0] = "f13",
  [1] = "f14",
  [2] = "f15",
  [3] = "f16",
  [4] = "f17",
  [5] = "f18",
}

-- ---------------------------------------------------------------------------
-- Internal state
-- ---------------------------------------------------------------------------

local state = {
  demos  = {},   -- keyed by slot number: { name=string, dir=string }
  active = nil,  -- currently active slot number, or nil
}

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

--- Scan SCRIPTS_DIR for N-<name> directories.
--- Returns a table keyed by slot number (1..MAX_DEMOS).
local function scanDemos()
  local demos = {}
  local iter, dir = hs.fs.dir(SCRIPTS_DIR)
  if not iter then
    return demos
  end
  for entry in iter, dir do
    if entry ~= "." and entry ~= ".." then
      local slot, name = entry:match("^(%d+)-(.+)$")
      if slot and name then
        slot = tonumber(slot)
        if slot >= 1 and slot <= MAX_DEMOS then
          local fullPath = SCRIPTS_DIR .. "/" .. entry
          local attr = hs.fs.attributes(fullPath)
          if attr and attr.mode == "directory" then
            demos[slot] = {
              name = name,
              dir  = entry,
            }
          end
        end
      end
    end
  end
  return demos
end

-- ---------------------------------------------------------------------------
-- Demo selection bindings (F-keys from Karabiner)
-- ---------------------------------------------------------------------------

--- F13 (ropt+0) — Deactivate all demos.
hs.hotkey.bind({}, SLOT_FKEYS[0], function()
  state.active = nil
  utils.notify("No demo active")
end)

--- F14-F18 (ropt+1..5) — Activate demo N.
for slot = 1, MAX_DEMOS do
  hs.hotkey.bind({}, SLOT_FKEYS[slot], function()
    -- Rescan each time so new demos are picked up without reload
    state.demos = scanDemos()
    local demo = state.demos[slot]
    if not demo then
      utils.notify("No demo in slot " .. tostring(slot))
      return
    end
    state.active = slot
    utils.notify("Demo: " .. demo.name)
  end)
end

-- ---------------------------------------------------------------------------
-- Step pasting bindings (ctrl+alt+cmd+M)
-- ---------------------------------------------------------------------------

for step = 1, MAX_STEPS do
  hs.hotkey.bind(MODS, tostring(step), function()
    if not state.active then
      return
    end

    local demo = state.demos[state.active]
    if not demo then
      return
    end

    local path = SCRIPTS_DIR .. "/" .. demo.dir .. "/" .. tostring(step) .. ".txt"
    local content = utils.readFile(path)
    if not content then
      utils.notify(demo.name .. ": no step " .. tostring(step))
      return
    end

    utils.typeTextAnimated(content)
  end)
end

-- ---------------------------------------------------------------------------
-- Startup
-- ---------------------------------------------------------------------------

state.demos = scanDemos()
local count = 0
for _ in pairs(state.demos) do count = count + 1 end
utils.notify(count .. " demo(s) found")
