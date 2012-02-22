(*
gtuckerkellogg   gmail com
Time-stamp: <2012-02-22 22:23:59 gtuckerkellogg>
$Id$

This is a application to assign Evernote tags in groups or sets

I commonly use collections of tags, and I like to remember what they
are.  With this I can assign groups of tags together.  I usually also
save a search for each group of tag.  The nice thing about this is
that I can use common names for tags that recur, while still retaining
the specificity that comes with multiple tags.

The first time you run it will ask you to create a new group.  There
is a configuration screen that comes up when running and cancelling
the selection.  Finally, you can create a new note in your default
notebook that will take a snapshot of your current tag groups.

This must be saved as an Application for tag groups to be persistent.
To call it from an Evernote menu system, do the following:

1. Open this script in the AppleScript editor and save it as an
   application

2. Open Automator and create an Automator service for
   Evernote to run the application

   It will then appear in the Evernote->Services menu

Optionally,

3. Open Services preferences and assign a keyboard shortcut to the
   menu item

*)

property tag_groups : {}

on run {}
	
	repeat while true
		repeat while the (count of tag_groups) < 1
			configure_dialog()
			if result is missing value then return
		end repeat
		
		pick_group from make_group_list(tag_groups)
		
		if result is not false then
			get_group(first item of result, tag_groups)
			assign_tags from result
			display_closing_dialog(the ntags of the result, the nnotes of the result)
			return
		else
			configure_dialog()
			if result is missing value then return
		end if
	end repeat
end run



# get_group(tagname, groups)
# Input: a name of a tag and the list of groups
# Output: the group itself (A record) or
# a missing value if not found

on get_group(tagname, groups)
	repeat with i from 1 to count of groups
		get item i of groups
		if (the key of result) is equal to (tagname as text) then
			return result
		end if
		
	end repeat
	return missing value
end get_group

# Do the business!
# take a set of tags and assign them to the selection
# 
on assign_tags from tagset
	set taglist to the value of tagset
	
	tell application "Evernote"
		set all_tags to tags
	end tell
	tell me to set selected_tags to get_tags_from_names(taglist, all_tags)
	#	return the class of the first item of selected_tags
	
	tell application "Evernote"
		set selected_notes to selection
		if (count of selected_tags) is greater than 0 and (count of selected_notes) is greater than 0 then
			assign selected_tags to selected_notes
		end if
		return {ntags:count of selected_tags, nnotes:count of selected_notes}
	end tell
end assign_tags

on make_group_list(groups)
	set the_list to {}
	repeat with group in groups
		set the end of the_list to the key of the group
	end repeat
	return the_list
end make_group_list


on pick_group from groups
	choose from list groups with title "Group Tagging"
end pick_group




on display_closing_dialog(num_tagged, num_selected)
	set the_text to "Assigned  "
	set the_text to the_text & pluralize("tag", num_tagged)
	set the_text to the_text & " to "
	set the_text to the_text & pluralize("note", num_selected)
	display dialog the_text buttons "OK"
end display_closing_dialog


# return a list of tags to be placed into a group
# creates a dialog box
# takes no parameters
# sorts the tag list

on select_tags_for_group_display(default_tags)
	tell application "Evernote"
		set all_tags to tags
		tell me to set all_tags to names_of_tags(all_tags)
		tell me to set all_tags to remove_dups(simple_sort(all_tags))
	end tell
	set the_selection to Â
		choose from list all_tags Â
			with title "Define a Tag Group" with prompt Â
			"Please choose a tags from the list below.  This will define a group " default items default_tags with multiple selections allowed
	if the_selection is false then
		return missing value
	end if
	return the_selection
end select_tags_for_group_display


on delete_group_dialog()
	set groups to make_group_list(tag_groups)
	set group_name to choose from list groups with title "Delete Group"
	if group_name is not false then
		set group_name to the first item of group_name
		set tmp_groups to {}
		repeat with i from 1 to count of groups
			if item i of groups is not equal to group_name then
				set the end of tmp_groups to item i of tag_groups
			end if
		end repeat
		set tag_groups to tmp_groups
		return true
	end if
	return missing value
end delete_group_dialog



on modify_group_dialog()
	set group_name to pick_group from make_group_list(tag_groups)
	if group_name is not false then
		set group_name to the first item of group_name
		set the_group to get_group(group_name as text, tag_groups)
		if the_group is not equal to missing value then
			set theTags to select_tags_for_group_display(the value of the_group)
			if theTags is not equal to missing value then
				return {key:group_name, value:theTags}
			end if
		end if
	end if
	return missing value
end modify_group_dialog


on define_new_group_dialog()
	display dialog "Choose a name for the group" with title "Create a new Tag group" default answer ""
	if button returned of result is not equal to "Cancel" then
		set group_name to text returned of result
		if get_group(group_name, tag_groups) is equal to missing value then
			set theTags to select_tags_for_group_display({})
			if theTags is not equal to missing value then
				return {key:group_name, value:theTags}
			end if
		else
			display alert group_name & " is already used as a group name"
		end if
	end if
	return missing value
end define_new_group_dialog


# configure_dialog()
# no input
# return false means high level cancel
# return missing means internal cancel
on configure_dialog()
	if the (count of tag_groups) is equal to 0 then
		define_new_group_dialog()
		if result is not equal to missing value then
			return define_group(tag_groups, result)
		end if
		return missing value
	end if
	set thechoice to choose from list {"Create a new group", "Delete an existing group", "Modify a group", "Create a note listing Tag Groups"} Â
		with prompt "What would you like to do"
	if thechoice is not equal to false then
		set thechoice to the first item of thechoice
		if thechoice is equal to "Create a new group" then
			define_new_group_dialog()
			if result is not equal to missing value then
				return define_group(tag_groups, result)
			end if
			return missing value
		else if thechoice is equal to "Modify a group" then
			modify_group_dialog()
			if result is not equal to missing value then
				return define_group(tag_groups, result)
			end if
		else if thechoice is equal to "Create a note listing Tag Groups" then
			textify_groups()
			return missing value
		else
			return delete_group_dialog()
		end if
	else
		return missing value
	end if
end configure_dialog


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
	return sorted_list
end simple_sort

on pluralize(a_noun, a_number)
	if a_number is greater than 1 then
		return a_number & " " & a_noun & "s"
	else
		return a_number & " " & a_noun
	end if
end pluralize



on names_of_tags(taglist)
	set name_list to {}
	repeat with theTag in taglist
		set the end of name_list to (the name of theTag as text)
	end repeat
	return name_list
end names_of_tags

on get_tags_from_names(namelist, taglist)
	try
		tell application "Evernote"
			set all_tags to tags
			set selected_tags to {}
			repeat with theTag in items in taglist
				if namelist contains (name of theTag as text) then
					set end of selected_tags to theTag
					
				end if
				
			end repeat
		end tell
	end try
	selected_tags
end get_tags_from_names


on define_group(tag_groups, tagset)
	set the_key to the key of tagset
	set existing_group to missing value
	repeat with i from 1 to count of tag_groups
		get item i of tag_groups
		if (the key of result as text) is equal to (the_key as text) then
			set existing_group to result
			exit repeat
		end if
	end repeat
	try
		if existing_group is not missing value then
			set item i of tag_groups to tagset
		else
			set the end of tag_groups to tagset
		end if
	end try
	return tag_groups
end define_group

on textify_groups()
	set the_text to ""
	repeat with i from 1 to count of tag_groups
		set the_text to the_text & return & return & the key of item i of tag_groups & ":  " & return
		repeat with j from 1 to count of the value of item i of tag_groups
			set the_text to the_text & "         " & item j of the value of item i of tag_groups
		end repeat
	end repeat
	set {year:y, month:m, day:d} to (current date) # extract elements of the date for the title
	set new_note_title to "Current Tag Groups as of " & date string of (current date) # this will be the title of your new note
	tell application "Evernote"
		create note with text the_text title new_note_title
	end tell
	return the_text
end textify_groups

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



