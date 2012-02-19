# Templates in Evernote (Mac version)
# gtuckerkellogg@gmail.com (inspired by http://veritrope.com/code/evernote-new-note-based-on-template/)
# No guarantees.  It works for me; use at your own risk

#------------ INSTALLATION -----------------
#
# Put this in a Run AppleScript container in Automator and associate with Evernote

#-------------THREE CONFIGURATION VARIABLES ----------

# 1. One notebook (by default, named "~meta") contains your template notes
# 2. One tag (by default, "templates") holds your templates
# 3. One notebook (by default, named "_inbox/in") will be used to place your new notes based on templates

# Change these to whatever you like. The notebooks must exist in order for the script to run.
# Any notes in the tag notebook tagged accordingly will be considered note templates

#------------  USAGE ---------------
# If you have this script installed as an Automator service, find it in Evernote->Services
# menu.  A dialog will appear allowing you to choose from your list of templates.  New
# notes will be created based on the templates, preserving tags (removing the template tag itself)
# and creating a date-stamped title based on the template note title.

####### 

global template_notebook
global template_tag
global new_note_notebook

set template_notebook to "~meta" # this is the Notebook where templates are stored
set template_tag to "template" # this is how templates are tagged
set new_note_notebook to "_inbox/in" # this is where new notes created from templates are placed

---------------- NO CONFIGURATION IS NEEDED BELOW THIS LINE --------------------

if check_notebook_existence() then
	set template_titles to get_template_titles()
	if template_titles is equal to {} then
		none_found()
	else
		set template_name to pick_template from template_titles
		if template_name is not equal to {} then
			create_note_using_template from template_name
		end if
	end if
end if

tell application "System Events" to set frontmost of process "Evernote" to true


----------------  SUBROUTINES -----------
on get_template_titles()
	set template_titles to {}
	tell application "Evernote"
		set template_list to find notes "notebook:\"" & template_notebook & "\" tag:" & template_tag
		repeat with my_note in template_list
			set template_titles to template_titles & {title of my_note}
		end repeat
	end tell
	return template_titles
end get_template_titles


on pick_template from template_list
	choose from list template_list
	if result is not false then
		set template_title to result
	else
		set template_title to {}
	end if
end pick_template


on create_new_note_title from template_title
	set {year:y, month:m, day:d} to (current date) # extract elements of the date for the title
	set new_note_title to template_title & " --- " & m & " " & d & ", " & y as string # this will be the title of your new note
	return new_note_title
end create_new_note_title


on create_note_using_template from template_title
	
	tell application "Evernote"
		set query_string to "notebook:\"" & template_notebook & "\" tag:\"" & template_tag & "\" inTitle:\"" & template_title & "\""
		set template_list to find notes query_string
		set template_note to item 1 of template_list
		tell me to set new_note_title to create_new_note_title from template_title
		set template_content to HTML content of template_note
		set new_note to ¬
			create note title new_note_title with html template_content ¬
				notebook new_note_notebook
		set the_tags to (the tags of template_note)
		assign the_tags to new_note
		repeat with T in the_tags
			if (name of T) is equal to template_tag then
				unassign T from new_note
			end if
		end repeat
		count (every item of the_tags)
		open note window with new_note
	end tell
end create_note_using_template


on check_notebook_existence()
	tell application "Evernote"
		try
			get the first notebook whose name is equal to new_note_notebook
		on error
			display dialog "The notebook for new notes: \"" & new_note_notebook & "\" does not exist"
			return false
		end try
		try
			get the first notebook whose name is equal to template_notebook
		on error
			display dialog "The notebook for templates: \"" & template_notebook & "\" does not exist"
			return false
		end try
	end tell
	return true
end check_notebook_existence


on none_found()
	display dialog ("No templates found") ¬
		& ("in notebook \"" & template_notebook & "\"" & return & return) ¬
		& ("with tag \"" & template_tag & "\"")
end none_found


