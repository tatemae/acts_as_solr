require 'acts_as_solr'
require 'rails'

module ActsAsSolr
  class Railtie < ::Rails::Railtie
    # Load rake tasks
    rake_tasks do
      load "tasks/database.rake"
      load "tasks/solr.rake"
      load "tasks/test.rake"
    end
  end
end