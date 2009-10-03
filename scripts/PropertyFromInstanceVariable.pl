#! /usr/bin/perl -w

#  Created by Matt Gallagher on 20/10/08.
#  Copyright 2008 Matt Gallagher. All rights reserved.
#
#  Enhancements by Yung-Luen Lan and Mike Schrag on 12/08/09.
#  (mainly: multiple lines)
#  Copyright 2009 Yung-Luen Lan and Mike Schrag. All rights reserved.
#
#  Enhancements by Pierre Bernard on 20/09/09.
#  (mainly: underbar storage name, behavior, dealloc,…)
#  Copyright 2009 Pierre Bernard. All rights reserved.
#
#  Permission is given to use this source code file without charge in any
#  project, commercial or otherwise, entirely at your risk, with the condition
#  that any redistribution (in part or whole) of source code must retain
#  this copyright and permission notice. Attribution in compiled projects is
#  appreciated but not required.

use strict;

# Get the header file contents from Xcode user scripts
my $headerFileContents = <<'HEADERFILECONTENTS';
%%%{PBXAllText}%%%
HEADERFILECONTENTS

# Get the indices of the selection from Xcode user scripts
my $selectionStartIndex = %%%{PBXSelectionStart}%%%;
my $selectionEndIndex = %%%{PBXSelectionEnd}%%%;



# Find the closing brace (end of the class variables section)
my $remainderOfHeader = substr $headerFileContents, $selectionEndIndex;
my $indexAfterClosingBrace = $selectionEndIndex + index($remainderOfHeader, "\n}\n") + 3;
if ($indexAfterClosingBrace == -1)
{
	exit 1;
}


# Get path of the header file
my $implementationFilePath = "%%%{PBXFilePath}%%%";
my $headerFilePath = $implementationFilePath;

# Look for an implemenation file with a ".m" or ".mm" extension
$implementationFilePath =~ s/\.[hm]*$/.m/;
if (!(-e $implementationFilePath))
{
	$implementationFilePath =~ s/.m$/.mm/;
}

# Stop now if the implementation file can't be found
if (!(-e $implementationFilePath))
{
	exit 1;
}


my $propertyDeclarations = '';
my $synthesizeStatements = '';
my $releaseStatements = '';



# Handle subroutine to trim whitespace off both ends of a string
sub trim
{
	my $string = shift;
	$string =~ s/^\s*(.*?)\s*$/$1/;
	return $string;
}

# Get the selection out of the header file
my $selectedText =  substr $headerFileContents, $selectionStartIndex, ($selectionEndIndex - $selectionStartIndex);
$selectedText = trim $selectedText;

my $selectedLine;
 
foreach $selectedLine (split(/\n+/, $selectedText)) {
	my $type = '';
	my $asterisk = '';
	my $name = '';
	my $behavior = '';

	# Test that the selection is:
	#  At series of identifiers (the type name and access specifiers)
	#  Possibly an asterisk
	#  Another identifier (the variable name)
	#  A semi-colon
	if (length($selectedLine) && ($selectedLine =~ /([_A-Za-z][_A-Za-z0-9]*\s*)+([\s\*]+)([_A-Za-z][_A-Za-z0-9]*);/))
	{
		$type = $1;
		$type = trim $type;
		$asterisk = $2;
		$asterisk = trim $asterisk;
		$name = $3;
		$behavior = 'assign';
	
		if (defined($asterisk) && length($asterisk) == 1)
		{
			if (($type eq 'NSString') || ($type eq 'NSArray') || ($type eq 'NSDictionary') || ($type eq 'NSSet'))
			{
				$behavior = 'copy';
			}
			else
			{
				if (($name =~ /Delegate/) || ($name =~ /delegate/) || ($type =~ /Delegate/) || ($type =~ /delegate/))
				{
					$behavior = 'assign';
				}
				else
				{
					$behavior = 'retain';
				}
			}
		}
		else
		{
			if ($type eq 'id')
			{
				$behavior = 'copy';
			}

			$asterisk = '';
		}
	}
	else
	{
		next;
	}

	my $storageName = '';

	if ($name =~ /_([_A-Za-z][_A-Za-z0-9]*)/) {
		$storageName = $name;
		$name = $1;		
	}


	# Create and insert the propert declaration
	my $propertyDeclaration = "\@property (nonatomic, $behavior) $type " . $asterisk . $name . ";\n";
	
	$propertyDeclarations = $propertyDeclarations . $propertyDeclaration;
	
	
	
	# Create and insert the synthesize statement 
	my $synthesizeStatement = '';
	
	if (length($storageName))
	{
		$synthesizeStatement = "\@synthesize $name = $storageName;\n";
	}
	else
	{
		$synthesizeStatement = 	"\@synthesize $name;\n";
	}
	
	$synthesizeStatements = $synthesizeStatements . $synthesizeStatement;
	
	
	
	# Create and insert release statement  
	my $releaseName = $name;
	my $releaseStatement = '';  
	
	if (length($storageName))
	{
		$releaseName = $storageName;  
	}
	
	if ($behavior eq 'assign')
	{
		if ($type eq 'SEL')
		{
			$releaseStatement = "\t$releaseName = NULL;\n";  
		}
	}
	else 
	{
		$releaseStatement = "\t[$releaseName release];\n\t$releaseName = nil;\n";  
	}
		
	$releaseStatements = $releaseStatements . $releaseStatement;
}

my $leadingNewline = '';
my $trailingNewline = '';

# Determine if we need to add a newline in front of the property declarations
if (substr($headerFileContents, $indexAfterClosingBrace, 1) eq "\n")
{
	$indexAfterClosingBrace += 1;
	$leadingNewline = '';
}
else
{
	$leadingNewline = "\n";
}

# Determine if we need to add a newline after the property declarations
if (substr($headerFileContents, $indexAfterClosingBrace, 9) eq '@property')
{
	$trailingNewline = '';
}
else
{
	$trailingNewline = "\n";
}

substr($headerFileContents, $indexAfterClosingBrace, 0) = $leadingNewline . $propertyDeclarations . $trailingNewline;

my $replaceFileContentsScript = <<'REPLACEFILESCRIPT';
on run argv
	set fileAlias to POSIX file (item 1 of argv)
	set newDocText to (item 2 of argv)
	tell application "Xcode"
		set doc to open fileAlias
		set text of doc to (text 1 thru -2 of newDocText)
	end tell
end run
REPLACEFILESCRIPT

# Use Applescript to replace the contents of the header file
# (I could have used the "Output" of the Xcode user script instead)
system 'osascript', '-e', $replaceFileContentsScript, $headerFilePath, $headerFileContents;



my $getFileContentsScript = <<'GETFILESCRIPT';
on run argv
	set fileAlias to POSIX file (item 1 of argv)
	tell application "Xcode"
		set doc to open fileAlias
		set docText to text of doc
	end tell
	return docText
end run
GETFILESCRIPT

# Get the contents of the implmentation file
open(SCRIPTFILE, '-|') || exec 'osascript', '-e', $getFileContentsScript, $implementationFilePath;
my $implementationFileContents = do {local $/; <SCRIPTFILE>};
close(SCRIPTFILE);

# Look for the class implementation statement
if (length($implementationFileContents) && ($implementationFileContents =~ /(\@implementation [_A-Za-z][_A-Za-z0-9]*\n)/))
{
	my $matchString = $1;
	my $indexAfterMatch = index($implementationFileContents, $matchString) + length($matchString);

	# Determine if we want a newline before the synthesize statement
	if (substr($implementationFileContents, $indexAfterMatch, 1) eq "\n")
	{
		$indexAfterMatch += 1;
		$leadingNewline = '';
	}
	else
	{
		$leadingNewline = "\n";
	}
	
	# Determine if we want a newline after the synthesize statement
	if (substr($implementationFileContents, $indexAfterMatch, 11) eq '@synthesize')
	{
		$trailingNewline = '';
	}
	else 
	{
		$trailingNewline = "\n";
	}

	substr($implementationFileContents, $indexAfterMatch, 0) = $leadingNewline. $synthesizeStatements . $trailingNewline;

	if ($implementationFileContents =~ /([ \t]*\[.*super.*dealloc.*\].*;.*\n)/)
	{  
		my $deallocMatch = $1;  
		my $indexAfterDeallocMatch = index($implementationFileContents, $deallocMatch);  

		substr($implementationFileContents, $indexAfterDeallocMatch, 0) = "$releaseStatements\n";  

	}
	elsif ($implementationFileContents =~ /(\@synthesize .*\n)*(\@synthesize [^\n]*\n)/s) {  
		my $synthesizeMatch = $2;  
 		my $indexAfterSynthesizeMatch = index($implementationFileContents, $synthesizeMatch) + length($synthesizeMatch);  
		my $deallocMethod = "\n- (void)dealloc\n{\n$releaseStatements\n\t[super dealloc];\n}\n";  

		substr($implementationFileContents, $indexAfterSynthesizeMatch, 0) = $deallocMethod;  
	}

	# Use Applescript to replace the contents of the implementation file in Xcode
	system 'osascript', '-e', $replaceFileContentsScript, $implementationFilePath, $implementationFileContents;
}

exit 0;
