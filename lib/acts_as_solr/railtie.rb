require 'acts_as_solr'
require 'rails'

module ActsAsSolr
  class Railtie < ::Rails::Railtie
    # Load rake tasks
    rake_tasks do
      load "acts_as_solr/tasks/database.rake"
      load "acts_as_solr/tasks/solr.rake"
      load "acts_as_solr/tasks/test.rake"
    end
  end
end