require 'test_helper'
require 'instance_methods'
require 'logger'

class InstanceMethodsTest < Test::Unit::TestCase
  include ActsAsSolr::InstanceMethods

  attr_accessor :configuration, :solr_configuration
  
  def logger
    @logger ||= Logger.new(STDOUT)
  end
  
  def record_id(obj)
    10
  end
  
  def boost_rate
    10.0
  end
  
  def irate
    8.0
  end

  def solr_name
    @solr_name
  end
  
  context "when checking whether indexing is disabled" do
    
    setup do
      @configuration = {:if => true}
    end
  
    should "return true if the specified proc returns true " do
      @configuration[:offline] = proc {|record| true}
      assert indexing_disabled?
    end
  
    should "return false if the specified proc returns false" do
      @configuration[:offline] = proc {|record| false}
      assert !indexing_disabled?
    end
  
    should "return true if no valid offline option was specified" do
      configuration[:offline] = nil
      configuration[:if] = proc {true}
      assert !indexing_disabled?
    end
  end

  context "when validating boost" do
    setup do
      @solr_configuration = {:default_boost => 10.0}
      @configuration = {:if => true}
    end
    
    should "accept and evaluate a block" do
      configuration[:boost] = proc {|record| record.boost_rate}
      assert_equal 10.0, validate_boost(configuration[:boost])
    end
  
    should "accept and return a float" do
       configuration[:boost] = 9.0
      assert_equal 9.0, validate_boost(configuration[:boost])
    end
  
    should "return the default float when the specified is negative" do
      configuration[:boost] = -1.0
      assert_equal 10.0, validate_boost(configuration[:boost])
    end
  
    should "execute the according method when value is a symbol" do
      configuration[:boost] = :irate
      assert_equal 8.0, validate_boost(configuration[:boost])
    end
  
    should "return the default boost when there is no valid boost" do
      configuration[:boost] = "boost!"
      assert_equal 10.0, validate_boost(configuration[:boost])
    end
  end
  
  context "when determining the solr document id" do
    should "combine class name and id" do
      assert_equal "InstanceMethodsTest:10", solr_id
    end
  end
  
  context "when saving the instance to solr" do
    context "with indexing disabled" do
      setup do
        @configuration = {:fields => [:name], :if => nil}
      end
  
      should "just return and do nothing" do
        self.expects(:solr_add).never
        self.expects(:solr_destroy).never
        assert solr_save
      end
    end
    
    context "with indexing enabled" do
      setup do
        @configuration = {:fields => [:name], :if => "true", :auto_commit => true}
        self.stubs(:solr_commit)
        self.stubs(:solr_add)
        self.stubs(:to_solr_doc).returns("My test document")
      end

      should "add the solr document" do
        self.expects(:solr_add).with("My test document").once
        solr_save
      end
      
      should "commit to solr" do
        self.expects(:solr_commit).once
        solr_save
      end
      
      should "not commit if auto_commit is disabled" do
        @configuration.merge!(:auto_commit => false)
        self.expects(:solr_commit).never
        solr_save
      end
      
      should "destroy the document if :if clause is false" do
        @configuration.merge!(:if => "false")
        self.expects(:solr_destroy).once
        solr_save
      end
    end
  end
end