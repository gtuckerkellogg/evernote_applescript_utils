AppleScript Utils for Evernote
==============================

This is just a set of simple AppleScripts that I use to make Evernote
on my Mac run more smoothly.

The scripts
-----------

### Tag multiple notes `en-multi-tag.applescript`


Allows tagging multiple notes with multiple tags, like the Ctrl-Alt-T keyboard shortcut on the Windows client.


### Create notes from templates `en_templates.applescript`

Allows creation of notes from templates.  Any notes with a specified
tag (default `template`) and in a specified folder (default `meta`)

### Add text to multiple note titles `add_text_to_note_titles.applescript`

Some people use keywords within note titles in addition to tags.  This
script will add arbitrary text to the titles of all selected notes.
The text can be added to the beginning or the end of the title.

### Tag multiple notes using "Tag Groups" `EN_Tag_Groups.applescript`

There are (at least) two camps within the Evernote user community
concerning the best way to tag notes.  Some people use a *lot* of tags,
with a high level of specificity.  Others (like me) use broader tags,
but combine them to achieve specific search results.  Still others use
low specificity tags and not very many of those, which I can't see
much use of.

For those of us who use broad tag categories, it can be useful to
ensure that the same tags are assigned to notes as they come in (say,
notes associated with a project).  This script will help do that.  The
first time it is run, it asks for a group name, and then lets you
assign a set of tags to that group.  It will then (and in future runs)
allow you to assign those tags to a set of notes.  It's like running
the multi-tag script above several times. 

Because this script creates some variables to persist over multiple
sessions, it will not work if run as a script from Automator.  It must
be run as an *Application* from Automator.

Installation and setup
----------------------

Just copying these scripts to a place where you can use them will work
at its most basic level.  However, if you want to get them to work as
shortcut keys within Evernote, you need to 

1. Save each script as an Application 
   
   You can do this by opening a Terminal and typing "rake".  The
   applications will all be in the `build` folder. 

2. Create a service using Automator for each Application 

3. Associate the name of the service with a keyboard shortcut

Instead of 2 and 3, you could just use TextExpander or your favorite
keyboard shortcut approach.  The only advantage with using Services is
that they will appear under the *Evernote->Services* menu.

Bugs and Limitations
---------------------

There are probably bugs.  Some of them are probaby mine.
Anyway, let me know if you see bugs.

### Why save these scripts as Applications instead of running AppleScript services?

Scripts run from Automator by a "run AppleScript" service pasted in to
the Automator window sometimes have undocumented limitations, even
though they work fine when run directly.  This has been reported by a
variety of AppleScript users and developers.  The workaround to get
keyboard shortcuts and working "Services" menu pulldowns is to save
them as Applications, as described above, and have the service run the
Application.

Acknowledgements
-----------------

Justin Lancy's [veritrope](http:/www.veritrope.com) is the best source
for Evernote AppleScripts, and is where I got familiar with the
problems others were having.  In particular the simple sort routine I
use is from Justin.  I'd put all my scripts directly on Veitrope, but
if I don't use git I'm lost.  So they are here
