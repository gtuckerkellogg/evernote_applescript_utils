-- -*- mode: Applescript -*-
-- Editing a Group of note titles
-- 
-- This is an AppleScript for manipulation of a set of Evernote notes.
-- When run, it modifies the titles of all selected notes by adding
-- text entered by the user.  The text can be added to the beginning
-- or the end of the note title.

on run {}
	tell application "Evernote"
		set selected_notes to selection
		if selected_notes is not equal to {} then
				set prefix to ""
			set suffix to ""
			set add_result to display dialog "text to be added" default answer
				"" buttons {"Cancel", "Prepend", "Append"}
				default button 
				"Append" with title "Add text to titles of selected notes"
			
			if (button returned of add_result) is not equal to "Cancel" then
				if button returned of add_result is equal to "Prepend" then
					set prefix to text returned of add_result & " "
				else
					set suffix to " " & text returned of add_result
				end if
				repeat with n in selected_notes
					set the title of n to (prefix & title of n & suffix)
				end repeat
			end if
		end if
	end tell
end run



