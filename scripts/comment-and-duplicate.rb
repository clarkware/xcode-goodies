#!/usr/bin/env ruby -w

# Duplicates and comments the original selected lines.

lines = STDIN.read

lines.each do |line|
  print "// #{line}"
end

lines.each do |line|
  print line
end
