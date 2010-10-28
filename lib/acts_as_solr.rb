# Copyright (c) 2006 Erik Hatcher, Thiago Jackiw
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'active_record'
require 'rexml/document'
require 'net/http'
require 'yaml'
require 'time'
require 'erb'
require 'rexml/xpath'

require File.dirname(__FILE__) + '/solr'
require File.dirname(__FILE__) + '/acts_as_solr/acts_methods'
require File.dirname(__FILE__) + '/acts_as_solr/common_methods'
require File.dirname(__FILE__) + '/acts_as_solr/parser_methods'
require File.dirname(__FILE__) + '/acts_as_solr/class_methods'
require File.dirname(__FILE__) + '/acts_as_solr/instance_methods'
require File.dirname(__FILE__) + '/acts_as_solr/common_methods'
require File.dirname(__FILE__) + '/acts_as_solr/deprecation'
require File.dirname(__FILE__) + '/acts_as_solr/search_results'
require File.dirname(__FILE__) + '/acts_as_solr/lazy_document'

require File.dirname(__FILE__) + '/acts_as_solr/railtie'

module ActsAsSolr
  
  class Post    
    def self.execute(request, core = nil)
      begin
        if File.exists?(::Rails.root+'/config/solr.yml')
          config = YAML::load_file(::Rails.root+'/config/solr.yml')
          url = config[ENV['RAILS_ENV']]['url']
          # for backwards compatibility
          url ||= "http://#{config[ENV['RAILS_ENV']]['host']}:#{config[ENV['RAILS_ENV']]['port']}/#{config[ENV['RAILS_ENV']]['servlet_path']}"
        else
          url = 'http://localhost:8982/solr'
        end
        url += "/" + core if !core.nil?
        connection = Solr::Connection.new(url)
        return connection.send(request)
      rescue 
        raise "Couldn't connect to the Solr server at #{url}. #{$!}"
        false
      end
    end
  end
  
end

# reopen ActiveRecord and include the acts_as_solr method
ActiveRecord::Base.extend ActsAsSolr::ActsMethods
