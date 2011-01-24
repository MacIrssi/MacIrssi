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

if execReturnStatus("git diff --quiet --cached") != 0 or execReturnStatus("git diff --quiet") != 0
  puts "error: Git index is not clean."
  exit 1
end

# Find the applications, check them and collect
apps = []
builtVersion = nil
Dir["#{ENV["BUILT_PRODUCTS_DIR"]}/*.app"].each do |app|
  compiledPlist = `pl < #{app}/Contents/Info.plist`
  compiledGitVersion = nil
  if /NSGitRevision\s+=\s+(.*?);/.match(compiledPlist)
    compiledGitVersion = $~[1]
  end
  
  if !builtVersion && /CFBundleVersion\s+=\s+"(.*?)"/.match(compiledPlist)
    builtVersion = $~[1]
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

unless builtVersion
  puts "error: Unable to determine version number of current build."
  exit 1
end

dmgRoot = "#{ENV["TEMP_DIR"]}/dmg"
dmgName = "#{ENV["PROJECT"]}-#{builtVersion}-#{ENV["CONFIGURATION"]}-#{Time.now.strftime('%d%m%y-%H%M')}-#{gitVersion}"

if File.exists?(dmgRoot)
  puts "Removing old DMG build root:\n\t#{dmgRoot}"
  FileUtils.rm_r(dmgRoot)
end

puts "Creating DMG build root:\n\t#{dmgRoot}"
unless FileUtils.mkdir_p(dmgRoot).length > 0
  puts "error: Unable to create DMG root #{dmgRoot}. Exiting."
  exit 1
end

templateDmg = "#{ENV["PROJECT_DIR"]}/#{ENV["PROJECT"]}-Template.sparseimage"
sparseDmgName = "#{dmgRoot}/#{dmgName}.sparseimage"
puts "Copying template DMG into build root.\n\t#{templateDmg} -> #{sparseDmgName}"
FileUtils.cp_r(templateDmg, sparseDmgName)

puts "Mounting new template:\n\t#{sparseDmgName}"
res = `hdiutil mount #{sparseDmgName}`
unless /Apple_HFS\s+(.*)/.match(res)
  puts "error: Unable to determine mount point for new sparse image."
  exit 1
end
mountLocation = $~[1]

puts "Copying applications into DMG image."
apps.each do |app|
  puts "\t#{app} -> #{mountLocation}"
  FileUtils.cp_r(app, mountLocation)
end

puts "Ejecting image.\n\t#{sparseDmgName}"
res = `hdiutil eject #{mountLocation}`
unless $? == 0
  puts "error: Unable to eject image #{sparseDmgName} at mount point #{mountLocation}. Exiting."
  exit 1
end

puts "Removing stale DMG files in build products."
Dir["#{ENV["BUILT_PRODUCTS_DIR"]}/*.dmg", "#{ENV["BUILT_PRODUCTS_DIR"]}/*.zip"].each do |stale|
  puts "\t#{stale}"
  unless FileUtils.rm(stale).length > 0
    puts "warning: Could not remove #{stale}"
  end
end
   
puts "Converting sparse image template into DMG.\n\t#{sparseDmgName} -> #{ENV["BUILT_PRODUCTS_DIR"]}/#{dmgName}.dmg"
res = `hdiutil convert #{sparseDmgName} -format UDBZ -o "#{ENV["BUILT_PRODUCTS_DIR"]}/#{dmgName}.dmg"`
unless $? == 0
  puts "error: Problem creating final DMG archive. #{res}"
  exit 1
end

# take all the dSYMs and zip them up into a nice package
puts "Zipping dSYMs."
res = `cd "#{ENV["BUILT_PRODUCTS_DIR"]}" && zip -r "#{ENV["BUILT_PRODUCTS_DIR"]}/#{dmgName}-dSYMs.zip" *.dSYM`
unless $? == 0
  puts "error: Problem zipping dSYMs. #{res}"
  exit 1
end
