-- =============================================================================
-- Hammerspoon Configuration — Demo Paste
-- =============================================================================
--
-- Minimal init that loads only the demo-paste module.
--
-- Hotkeys (via Karabiner remap):
--   ropt+0 (-> F13)            Deactivate demo (step keys do nothing).
--   ropt+1..5 (-> F14..F18)    Activate demo N.
--   ctrl+alt+cmd+1..9           Paste step M of the active demo.
--
-- Demo scripts:
--   ~/demo-scripts/N-<name>/1.txt .. 9.txt
--
-- =============================================================================

require("lib.demo-paste")
