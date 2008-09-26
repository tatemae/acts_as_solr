class Gadget < ActiveRecord::Base
  acts_as_solr :offline => proc {|record| Gadget.search_disabled?}
  
  def self.search_disabled?
    true
  end
end