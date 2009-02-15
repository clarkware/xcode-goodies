#!/usr/bin/env ruby -w

# Xcode auto-versioning script for git
#
# Based on original Perl script by Marcus S. Zarra and Matt Long at
# (http://www.cimgf.com/2008/04/13/git-and-xcode-a-git-build-number-script/)

require "rubygems"
require "Plist"

raise "Must be run from Xcode" unless ENV['XCODE_VERSION_ACTUAL']

plist_file = ENV['INFOPLIST_FILE']
 
git = `sh /etc/profile; which git`.chomp
revision = `#{git} rev-parse --short HEAD`.chomp!

plist = Plist::parse_xml(plist_file)
plist["CFBundleVersion"] = revision
plist.save_plist(plist_file)
 
puts "Updated #{plist_file}"
puts "Set CFBundleVersion to '#{revision}'!"
