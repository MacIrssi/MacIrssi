#!/usr/bin/env ruby

require 'fileutils'
require 'date'

# Packaging script to replace the shitty shell script I had
# previously.

# Sadly, plist isn't a standard module, so we'll do this with
# regex

def execReturnStatus(str)
  `#{str}`
  return $?
end

gitVersion = `git show-ref --hash --abbrev --head HEAD | head -1`.chomp

PLIST=`pl < #{ENV["PRODUCT_SETTINGS_PATH"]}`
builtVersion = nil
if /CFBundleVersion\s+=\s+"(.*?)"/.match(PLIST)
  builtVersion = $~[1]
end

unless builtVersion
  puts "error: Unable to determine version number of current build."
  exit 1
end

if execReturnStatus("git diff --quiet --cached") != 0 or execReturnStatus("git diff --quiet") != 0
  puts "error: Git index is not clean."
  exit 1
end

# Find the applications, check them and collect
apps = []
Dir["#{ENV["BUILT_PRODUCTS_DIR"]}/*.app"].each do |app|
  compiledPlist = `pl < #{app}/Contents/Info.plist`
  compiledGitVersion = nil
  if /NSGitRevision\s+=\s+(.*?);/.match(compiledPlist)
    compiledGitVersion = $~[1]
  end
  
  unless compiledGitVersion and compiledGitVersion != ""
    puts "warning: Unable to read plist of #{app}, skipping."
    next
  end
  
  unless gitVersion == compiledGitVersion
    puts "error: Current binary #{app} (#{compiledGitVersion}) was not build with the current git HEAD (#{gitVersion}). Exiting."
    exit 1
  end
  
  apps << app
end

tmpRoot = "#{ENV["TEMP_DIR"]}/dmg"
dmgRoot = "#{tmpRoot}/#{ENV["PROJECT"]}"
dmgName = "#{ENV["PROJECT"]}-#{builtVersion}-#{ENV["CONFIGURATION"]}-#{Time.now.strftime('%d%m%y-%H%M')}-#{gitVersion}.dmg"

if File.exists?(tmpRoot)
  puts "Removing old DMG build root:\n\t#{tmpRoot}"
  FileUtils.rm_r(tmpRoot)
end

puts "Creating DMG build root:\n\t#{dmgRoot}"
unless FileUtils.mkdir_p(dmgRoot).length > 0
  puts "error: Unable to create DMG root #{dmgRoot}. Exiting."
  exit 1
end

puts "Copying applications into DMG build root."
apps.each do |app|
  puts "\t#{app}"
  FileUtils.cp_r(app, dmgRoot)
end

puts "Building DMG.\n\t#{dmgName}"
res = `hdiutil create -ov -srcfolder "#{dmgRoot}" "#{dmgRoot}/#{dmgName}"`
unless $? == 0
  puts "error: hdiutil exited with non-zero status. #{res}."
  exit 1
end

puts "Removing stale DMG files in build products."
Dir["#{ENV["BUILT_PRODUCTS_DIR"]}/*.dmg"].each do |stale|
  puts "\t#{stale}"
  unless FileUtils.rm(stale).length > 0
    puts "warning: Could not remove #{stale}"
  end
end
  
puts "Moving DMG to build products."
puts "\t#{dmgName} -> #{ENV["BUILT_PRODUCTS_DIR"]}"
FileUtils.mv("#{dmgRoot}/#{dmgName}", ENV["BUILT_PRODUCTS_DIR"])
