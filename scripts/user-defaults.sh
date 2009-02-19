#!/bin/sh

# Xcode User Default Overrides

# Specifies whether Xcode displays a warning when an undo operation on an 
# open file would take it to a state prior to the file's last save operation.
#
# Default: YES
defaults write com.apple.XCode XCShowUndoPastSaveWarning NO

# FunctionBlockSeparator: Whitespace after a method or function name and 
# argument-list declarations and its body.  Default: "\n"
#
# PreMethodDeclSpacing: Whitespace between the parenthesized return type 
# and the method name in an Objective-C method declaration. Default: " " 
defaults write com.apple.XCode XCCodeSenseFormattingOptions \
  -dict FunctionBlockSeparator " " PreMethodDeclSpacing ""
