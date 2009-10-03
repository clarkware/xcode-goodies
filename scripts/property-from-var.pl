#! /usr/bin/perl -w

# Author:  Matt Maher
# Enhanced by:  Kendall Gelner

#Script to turn one selected class local variable into property definition, 
#along with synthesize statement.

# copy all this text into a new user script with settings:
#Input: Selection
#Directory: Selection
#Output: Show in Alert
#Errors: Show In Alert

use strict;

# Get the header file contents from Xcode user scripts
my $headerFileContents = <<'HEADERFILECONTENTS';
%%%{PBXAllText}%%%
HEADERFILECONTENTS

# Get the indices of the selection from Xcode user scripts
my $selectionStartIndex = %%%{PBXSelectionStart}%%%;
my $selectionEndIndex = %%%{PBXSelectionEnd}%%%;

# Get path of the header file
my $implementationFilePath = "%%%{PBXFilePath}%%%";
my $headerFilePath = $implementationFilePath;

# Look for an implemenation file with a ".m" or ".mm" extension
$implementationFilePath =~ s/\.[hm]*$/.m/;
if (!(-e $implementationFilePath))
{
    $implementationFilePath =~ s/.m$/.mm/;
}

# Handle subroutine to trime whitespace off both ends of a string
sub trim
{
    my $string = shift;
    $string =~ s/^\s*(.*?)\s*$/$1/;
    return $string;
}

# Get the selection out of the header file
my $selectedText =  substr $headerFileContents, $selectionStartIndex, ($selectionEndIndex - $selectionStartIndex);
$selectedText = trim $selectedText;

my $type = "";
my $asterisk = "";
my $name = "";
my $behavior = "";
my $iboutlet = "";

# Test that the selection is:
#  At series of identifiers (the type name and access specifiers)
#  Possibly an asterisk
#  Another identifier (the variable name)
#  A semi-colon
if (length($selectedText) && ($selectedText =~ /([_A-Za-z][_A-Za-z0-9]*\s*)+([\s\*]+)([_A-Za-z][_A-Za-z0-9]*);/))
{
    $type = $1;
    $type = trim $type;
    $asterisk = $2;
    $asterisk = trim $asterisk;
    $name = $3;
    $behavior = "";
    if (defined($asterisk) && length($asterisk) == 1)
    {
        $behavior = "(nonatomic, retain) ";
    }
    else
    {
        $behavior = "(nonatomic) ";
        $asterisk = "";
    }
}
else
{
    exit 1;
}

# special case, see if we need to keep around an IBOUTLET declaration.
if ( length($selectedText) && ($selectedText =~ /IBOutlet/) )
{
   $iboutlet = "IBOutlet ";
}

# Find the closing brace (end of the class variables section)
my $remainderOfHeader = substr $headerFileContents, $selectionEndIndex;
my $indexAfterClosingBrace = $selectionEndIndex + index($remainderOfHeader, "\n}\n") + 3;
if ($indexAfterClosingBrace == -1)
{
    exit 1;
}

# Determine if we need to add a newline in front of the property declaration
my $leadingNewline = "\n";
if (substr($headerFileContents, $indexAfterClosingBrace, 1) eq "\n")
{
    $indexAfterClosingBrace += 1;
    $leadingNewline = "";
}

# Determine if we need to add a newline after the property declaration
my $trailingNewline = "\n";
if (substr($headerFileContents, $indexAfterClosingBrace, 9) eq "\@property")
{
    $trailingNewline = "";
}

# Create and insert the proper declaration
my $propertyDeclaration = $leadingNewline . "\@property " . $behavior . $iboutlet . $type . " " . $asterisk . $name . ";\n" . $trailingNewline; 
substr($headerFileContents, $indexAfterClosingBrace, 0) = $propertyDeclaration;

my $replaceFileContentsScript = <<'REPLACEFILESCRIPT';
on run argv
    set fileAlias to POSIX file (item 1 of argv)
    set newDocText to (item 2 of argv)
    tell application "Xcode"
        set doc to open fileAlias
        set text of doc to newDocText
    end tell
end run
REPLACEFILESCRIPT

# Use Applescript to replace the contents of the header file
# (I could have used the "Output" of the Xcode user script instead)
system 'osascript', '-e', $replaceFileContentsScript, $headerFilePath, $headerFileContents;

# Stop now if the implementation file can't be found
if (!(-e $implementationFilePath))
{
    exit 1;
}

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
    $leadingNewline = "\n";
    if (substr($implementationFileContents, $indexAfterMatch, 1) eq "\n")
    {
        $indexAfterMatch += 1;
        $leadingNewline = "";
    }

    # Determine if we want a newline after the synthesize statement
    $trailingNewline = "\n";
    if (substr($implementationFileContents, $indexAfterMatch, 11) eq "\@synthesize")
    {
        $trailingNewline = "";
    }

    # Create and insert the synthesize statement 
    my $synthesizeStatement = $leadingNewline . "\@synthesize " . $name . ";\n" . $trailingNewline;
    substr($implementationFileContents, $indexAfterMatch, 0) = $synthesizeStatement;
    
    # Use Applescript to replace the contents of the implementation file in Xcode
    system 'osascript', '-e', $replaceFileContentsScript, $implementationFilePath, $implementationFileContents;
}

exit 0;
