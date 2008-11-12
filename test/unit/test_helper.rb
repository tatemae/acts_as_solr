$:.unshift(File.join(File.expand_path(File.dirname(__FILE__)), "..", "..", "lib"))

require 'rubygems'
gem 'thoughtbot-shoulda'
require 'shoulda'
require 'test/unit'
require 'mocha'