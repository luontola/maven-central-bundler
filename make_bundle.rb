#!/usr/local/bin/ruby
# Copyright © 2011-2013, Esko Luontola <www.orfjackal.net>
# This software is released under the Apache License 2.0.
# The license text is at http://www.apache.org/licenses/LICENSE-2.0

require File.dirname(__FILE__) + '/lib/bundler'

if ARGV.length == 0
  puts 'Maven Central Bundler, https://github.com/orfjackal/maven-central-bundler'
  puts "Usage: #{File.basename(__FILE__)} --pom FILE --jar FILE --sources FILE [--CLASSIFIER FILE]..."
  puts
  puts 'Copyright (c) 2011-2013, Esko Luontola <www.orfjackal.net>'
  puts 'This software is released under the Apache License 2.0.'
  puts 'The license text is at http://www.apache.org/licenses/LICENSE-2.0'
  exit 1
end

bundler = Bundler.new

ARGV.each_slice(2).each { |pair|
  arg = pair[0]
  path = pair[1]
  raise "Unknown argument: #{arg}" unless arg.start_with?('--')
  raise "Missing parameter for #{arg}" unless path
  raise "File not found: #{path}" unless File.exist?(path)
  classifier = arg.sub(/^--/, '').to_sym

  bundler.add_artifact classifier, path
}

bundler.create 'bundle'
