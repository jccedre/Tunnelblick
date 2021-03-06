#!/usr/bin/env ruby
# Xcode auto-versioning script for Subversion
# by Axel Andersson, modified by Daniel Jalkut to add
# "--revision HEAD" to the svn info line, which allows
# the latest revision to always be used.

if ENV["BUILT_PRODUCTS_DIR"].nil?
	STDERR.print "#{$0}: Must be run from Xcode!"
	exit(1)
end

# Get the current Bzr revision number and use it to set the CFBundleVersion value
ENV["PATH"] = "/bin:/sw/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/opt/local/bin"
exit(0) if `type bzr` == ""
rev = `/usr/bin/env bzr revno`
info = "#{ENV["BUILT_PRODUCTS_DIR"]}/#{ENV["WRAPPER_NAME"]}/Resources/Info.plist"
version = rev[/[\d.]+/]

if version.nil?
	STDERR.print "#{$0}: Can't find a Bazaar revision!"
	exit(0)
end

info_contents = File.read(info)
if info_contents.nil?
	STDERR.print "#{$0}: Can't read in the Info.plist file!"
	exit(1)
end

info_contents.sub!(/([\t ]+<key>CFBundleVersion<\/key>\n[\t ]+<string>).*?(<\/string>)/, '\1' + version + '\2')
STDERR.print info_contents
f = File.open(info, "w")
f.write(info_contents)
f.close
