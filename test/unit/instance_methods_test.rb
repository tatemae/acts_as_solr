require 'test/unit'
require 'instance_methods'

class InstanceMethodsTest < Test::Unit::TestCase
  include ActsAsSolr::InstanceMethods
  attr_accessor :configuration, :solr_configuration

  def boost_rate
    10.0
  end

  def irate
    8.0
  end
  
  def setup
    @configuration = {:if => true}
    @solr_configuration = {:default_boost => 10.0}
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
  
  def test_validate_boost_should_accept_and_evaluate_a_block
    configuration[:boost] = proc {|record| record.boost_rate}
    assert_equal 10.0, validate_boost(configuration[:boost])
  end
  
  def test_validate_boost_should_accept_and_return_a_float
    configuration[:boost] = 9.0
    assert_equal 9.0, validate_boost(configuration[:boost])
  end
  
  def test_validate_boost_should_return_the_default_float_when_boost_is_negative
    configuration[:boost] = -1.0
    assert_equal 10.0, validate_boost(configuration[:boost])
  end
  
  def test_should_execute_method_when_boost_is_symbol
    configuration[:boost] = :irate
    assert_equal 8.0, validate_boost(configuration[:boost])
  end
  
  def test_should_return_the_default_when_there_was_no_match
    configuration[:boost] = "boost!"
    assert_equal 10.0, validate_boost(configuration[:boost])
  end
end