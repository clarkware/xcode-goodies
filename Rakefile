require 'rake/clean'
require "Plist"
require 'fileutils'
include FileUtils

def base_dir
  File.dirname(__FILE__)
end

def build_dir
  File.join(base_dir, 'build')
end


def command(name)
  path = `sh /etc/profile; which #{name}`.chomp
  unless File.executable?(path)
    raise "Unable to find command '#{name}' in the $PATH."
  end
  path
end

desc 'Display the code signature info for the iPhone build'
task :iphone_app_info do
  raise "No build artifacts" unless File.directory?(build_dir)
  dirs = %w(Debug Release).map { |pre| File.join(build_dir, "#{pre}-iphoneos") }
  dirs.each do |dir|
    Dir["#{dir}/*.app"].each do |app|
      puts "\nApplication: #{app}"
      puts `codesign -dvvvv #{app}`
    end
  end
end

desc 'Display all the bundle versions'
task :bundle_versions do
  raise "No build artifacts" unless File.directory?(build_dir)
  Dir["#{build_dir}/**/Info.plist"].each do |path|
    if File.file?(path)
      plist = Plist::parse_xml(path)
      if plist
        puts "\nPlist File: #{path}"
        puts "CFBundleVersion: #{plist["CFBundleVersion"]}".strip
      end
    end
  end
end

desc 'Run the Clang static analyzer'
task :analyze do
  begin
    sh "#{command('scan-build')} -V xcodebuild clean build -configuration Debug"
  rescue
    puts "You'll need to install the LLVM/Clang Static Analyzer"
    puts "http://clang.llvm.org/StaticAnalysis.html"
    puts "Then add the directory with the 'scan-build' binary to your $PATH"
  end
end

desc 'Compile the XIBs to NIBs, and emit any problems'
task :compile_nibs do  
  ibtool = "ibtool --errors --warnings --notices --output-format human-readable-text"
  Dir["#{base_dir}/*.xib"].each do |path|
    sh "#{ibtool} --compile output.nib #{path}"
  end
  rm_f 'output.nib'
end

desc 'Clean build artifacts'
task :clean do
  sh "xcodebuild clean"
end
