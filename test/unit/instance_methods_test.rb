require 'test/unit'
require 'instance_methods'

class InstanceMethodsTest < Test::Unit::TestCase
  include ActsAsSolr::InstanceMethods
  attr_accessor :configuration
  
  def setup
    @configuration = {:if => true}
  end
  
  def test_indexing_disabled_should_return_true_if_offline_condition_is_true
    @configuration[:offline] = proc {|record| true}
    assert indexing_disabled?
  end
  
  def test_indexing_disabled_should_return_false_if_offline_condition_is_false
    @configuration[:offline] = proc {|record| false}
    assert !indexing_disabled?
  end
  
  def test_indexing_disabled_should_return_true_if_no_if_option_was_specified
    configuration[:offline] = false
    configuration[:if] = proc {true}
    assert !indexing_disabled?
  end
end