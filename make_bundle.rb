#!/usr/local/bin/ruby

require File.dirname(__FILE__) + '/lib/bundler'

if ARGV.length == 0
  puts "Usage: #{File.basename(__FILE__)} --pom FILE --jar FILE --sources FILE [--CLASSIFIER FILE]..."
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
