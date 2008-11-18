$:.unshift(File.join(File.expand_path(File.dirname(__FILE__)), "..", "..", "lib"))

require 'rubygems'
gem 'thoughtbot-shoulda'
require 'shoulda'
if RUBY_VERSION =~ /^1\.9/
  require 'minitest/unit'
else
  require 'test/unit'
  require 'mocha'
end
