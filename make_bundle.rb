#!/usr/local/bin/ruby

require File.dirname(__FILE__) + '/lib/bundler'

if ARGV.length < 3
  puts "Usage: #{File.basename(__FILE__)} POM JAR SOURCES_JAR [JAVADOC_JAR]"
  exit 1
end

pom = ARGV[0]
jar = ARGV[1]
sources = ARGV[2]
javadoc = false
javadoc = ARGV[3] if ARGV.length > 3

bundler = Bundler.new
bundler.set_options :pom => pom, :jar => jar, :sources => sources, :javadoc => javadoc
bundler.create 'bundle'
