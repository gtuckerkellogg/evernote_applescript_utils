(* -*- Mode: Applescript -*-

# Multi-tag notes in Evernote by Applescript
#
# Analogous to Ctrl-Alt-T in Windows Application
# Author: gtuckerkellogg gmail.com 
# Very hackish
# No guarantees, works for me.

*)

on run {}
	tell application "Evernote"
		activate
		set all_tags to tags
		set num_selected to the count of selection
		if the num_selected is 0 then
			display dialog "Nothing is selected" buttons "OK"
			return
		end if
		
	end tell
	
	set sorted_tag_names to remove_dups(sorted_version of simple_sort(names_of_tags(all_tags)))
	
	activate me
	--	choose from list sorted_version of sorted_tag_names Â
	choose from list sorted_tag_names Â
		with title "Assign Tags" with multiple selections allowed
	
	if result is not false then
		set selected_tags to get_tags_from_names(result, all_tags)
		set num_tagged to count of selected_tags
		assign_tags_to_selected(selected_tags)
		display_closing_dialog(num_tagged, num_selected)
	end if
	activate application "Evernote"
end run


on display_closing_dialog(num_tagged, num_selected)
	set the_text to "Assigned  "
	set the_text to the_text & pluralize("tag", num_tagged)
	set the_text to the_text & " to "
	set the_text to the_text & pluralize("note", num_selected)
	display dialog the_text buttons "OK"
end display_closing_dialog



on pluralize(a_noun, a_number)
	if a_number is greater than 1 then
		return a_number & " " & a_noun & "s"
	else
		return a_number & " " & a_noun
	end if
end pluralize

on assign_tags_to_selected(theTags)
	tell application "Evernote"
		set noteList to selection
		assign theTags to noteList
	end tell
end assign_tags_to_selected


on get_tags_from_names(namelist, taglist)
	try
		tell application "Evernote"
			set selected_tags to {}
			repeat with theTag in items in taglist
				# display dialog (name of theTag as text)
				if namelist contains (name of theTag as text) then
					set end of selected_tags to theTag
					
				end if
				
			end repeat
		end tell
	end try
	selected_tags
end get_tags_from_names



on names_of_tags(taglist)
	set name_list to {}
	repeat with theTag in taglist
		set the end of name_list to (the name of theTag as text)
	end repeat
	return name_list
end names_of_tags


--SORT SUBROUTINE-- from veritrope

on simple_sort(my_list)
	set the index_list to {}
	set the sorted_list to {}
	repeat (the number of items in my_list) times
		set the low_item to ""
		repeat with i from 1 to (number of items in my_list)
			if i is not in the index_list then
				set this_item to item i of my_list as text
				if the low_item is "" then
					set the low_item to this_item
					set the low_item_index to i
				else if this_item comes before the low_item then
					set the low_item to this_item
					set the low_item_index to i
				end if
			end if
		end repeat
		set the end of sorted_list to the low_item
		set the end of the index_list to the low_item_index
	end repeat
	return {sorted_version:sorted_list, sorting_index:index_list}
end simple_sort

-- This is because Evernote returns duplicate tag names.
on remove_dups(sorted_list)
	set the_unique_list to {}
	set the end of the_unique_list to the first item of sorted_list
	repeat with i from 2 to (number of items in sorted_list)
		set this_item to item i of sorted_list
		if this_item is not equal to the last item of the_unique_list then
			set the end of the_unique_list to this_item
		end if
	end repeat
	return the_unique_list
end remove_dups

