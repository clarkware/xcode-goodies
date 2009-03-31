#!/usr/bin/osascript

-- Repositions the Xcode window to be centered in the screen
-- and sized according to windowWidth/windowHeight.
--
-- The easiest way to use this is to add it as your Xcode
-- User Scripts and assign a keyboard shortcut.

set windowWidth to 1000
set windowHeight to 800

tell application "Finder"
  set {screen_top, screen_left, screen_width, screen_height} to bounds of window of desktop
end tell

tell application "Finder"
  set {desktopTop, desktopLeft, desktopRight, desktopBottom} to bounds of desktop
end tell

tell application "System Events"
  set frontItem to name of first item of (processes whose frontmost is true)
end tell

tell application "System Events"
  tell process frontItem
    set position of window 1 to {((screen_width - windowWidth) / 2), ((screen_height - windowHeight) / 4) - desktopTop}
    set size of window 1 to {windowWidth, windowHeight}
  end tell
end tell
