#!/usr/bin/env ruby -w
 
# When instance variables are selected, this user script creates
# @property statements in header files, and puts @synthesize statements 
# and a dealloc method on the pasteboard.

# Based on original script by Craig Williams at
# (http://allancraig.net/blog/?p=315)
 
properties  = ''
synthesize  = ''
release     = ''
 
STDIN.read.each do |line|
  line.gsub!(/\*/, '').strip!
  words = line.split(/\s+/)
 
  label =  words.size > 2 ? words[1] : words[0]
  variable = words[-1]
  properties << "@property (nonatomic, retain) #{label} *#{variable}\n"
  synthesize << "@synthesize #{variable}\n"
  release    << "[#{variable.chop} release];\n"
end
 
synthesize << release.chomp
 
`echo '#{synthesize.chomp}' | pbcopy`
print properties.chomp
