#!/usr/bin/env perl
# Xcode auto-versioning script for Subversion by Axel Andersson
# Updated for git by Marcus S. Zarra and Matt Long
 
use strict;
 
# Get the current git commit hash and use it to set the CFBundleVersion value
my $REV = `git show-ref --hash --abbrev --head HEAD | head -1`;
my $INFO = "$ENV{BUILT_PRODUCTS_DIR}/$ENV{WRAPPER_NAME}/Contents/Info.plist";
 
my $version = $REV;
die "$0: No Git revision found" unless $version;
 
chomp($version);

open(FH, "$INFO") or die "$0: $INFO: $!";
my $info = join("", <FH>);
close(FH);
 
$info =~ s/([\t ]+<key>NSGitRevision<\/key>\n[\t ]+<string>).*?(<\/string>)/$1$version$2/;
 
open(FH, ">$INFO") or die "$0: $INFO: $!";
print FH $info;
close(FH);
