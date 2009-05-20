$:.unshift(File.join(File.expand_path(File.dirname(__FILE__)), "..", "..", "lib"))

require 'rubygems'
require 'test/unit'
require 'acts_as_solr'
require 'mocha'
require 'active_support'
require 'logger'
require 'solr_instance'
require 'parser_instance'
require 'erb'
require 'ostruct'

if RUBY_VERSION =~ /^1\.9/
  puts "\nRunning the unit test suite doesn't as of yet work with Ruby 1.9, because Mocha hasn't yet been updated to use minitest."
  puts
  exit 1
end

require 'mocha'
gem 'thoughtbot-shoulda'
require 'shoulda'
