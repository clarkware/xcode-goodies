--GNU		Standard GNU applies
--
--Date:		Thursday February 5, 2009 
--Author: 	Craig Williams
--Link:         http://allancraig.net
--Desc:		Run the Clang Static Analyzer from Xcode using AppleScript
 
tell application "Xcode"
	try
		set openProjects to every project
	on error
		display dialog "No Projects Open"
		return
	end try
 
	set projectList to {}
	if (count of openProjects) is greater than 1 then
		repeat with i from 1 to count of openProjects
			set thisProj to item i of openProjects
			set end of projectList to (name of thisProj)
		end repeat
		set chosenProj to choose from list projectList ¬
			with title ¬
			"Choose project to run clang against." with prompt "Choose Project"
		if chosenProj is false then return
		set theProject to item 1 of chosenProj
		set theProject to project theProject
	else
		set theProject to project 1
	end if
	my runClang(project directory of theProject)
end tell
 
on runClang(projectPath)
	set clangCmd to "cd " & quoted form of projectPath & ";"
	set clangCmd to clangCmd & "scan-build -V xcodebuild clean build"
 
	tell application "Terminal"
		activate
		do script with command clangCmd
	end tell
end runClang
