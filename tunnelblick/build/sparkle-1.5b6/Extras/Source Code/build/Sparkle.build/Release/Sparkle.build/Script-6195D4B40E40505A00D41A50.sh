#!/usr/bin/env ruby
resources = "#{ENV["BUILT_PRODUCTS_DIR"]}/#{ENV["WRAPPER_NAME"]}/Resources"
`ln -s "fr.lproj" "#{resources}/fr_CA.lproj"`
