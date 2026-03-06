-- =============================================================================
-- lib/utils.lua — Shared utility functions
-- =============================================================================
-- Used by: lib/demo-paste.lua
--
-- Functions:
--   utils.notify(msg)           Show a macOS notification.
--   utils.fileExists(path)      Return true if path is readable.
--   utils.readFile(path)        Return file contents as string, or nil.
--   utils.trim(s)               Strip leading/trailing whitespace.
--   utils.typeText(text)        Type text via keyboard events (no clipboard).
-- =============================================================================

local M = {}

M.HOME = os.getenv("HOME")

--- Show a macOS notification.
--- @param msg string  Notification message.
function M.notify(msg)
  hs.notify.new({
    title = msg or "",
  }):send()
end

--- Return true if the file at `path` can be opened for reading.
function M.fileExists(path)
  local f = io.open(path, "r")
  if f then
    f:close()
    return true
  end
  return false
end

--- Read an entire file into a string. Returns nil if the file cannot be opened.
function M.readFile(path)
  local f = io.open(path, "r")
  if not f then
    return nil
  end
  local content = f:read("*a")
  f:close()
  return content
end

--- Strip leading and trailing whitespace from a string.
function M.trim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

--- Type text into the focused field via keyboard events.
--- Does not touch the clipboard. Suitable for use from hotkey callbacks where
--- held modifier keys would interfere with clipboard-based pasting.
function M.typeText(text)
  hs.eventtap.keyStrokes(text)
end

return M
