require 'test_helper'
require 'parser_methods'
require 'search_results'
require 'deprecation'
module Solr; module Request; end; end
require 'solr/request/base'
require 'solr/request/select'
require 'solr/request/standard'

class ActsAsSolr::Post; end

class ParserMethodsTest < Test::Unit::TestCase
  include ActsAsSolr::ParserMethods
  attr_accessor :configuration, :solr_configuration
  
  def table_name
    "documents"
  end
  
  def primary_key
    "id"
  end
  
  def find(*args)
    []
  end
  
  context "When parsing results" do
    setup do
      @results = stub(:results)
      @results.stubs(:total_hits).returns(2)
      @results.stubs(:hits).returns([])
      @results.stubs(:max_score).returns 2.1
      @results.stubs(:data).returns({"responseHeader" => {"QTime" => "10.2"}})
    end
    
    should "return a SearchResults object" do
      assert_equal ActsAsSolr::SearchResults, parse_results(@results).class
    end
    
    should "set the max score" do
      assert_equal 2.1, parse_results(@results).max_score
    end
    
    should "include the facets" do
      @results.stubs(:data).returns({"responseHeader" => {"QTime" => "10.2"}, "facet_counts" => 2})
      assert_equal 2, parse_results(@results, :facets => true).facets
    end

    context "when the format requests objects" do
      setup do
        @configuration = {:format => :objects}
        @solr_configuration = {:primary_key_field => :pk_id}
        @results.stubs(:hits).returns [{"pk_id" => 1}, {"pk_id" => 2}]
        stubs(:reorder)
      end
      
      should "query with the record ids" do
        expects(:find).with(:all, :conditions => ["documents.id in (?)", [1, 2]]).returns [1, 2]
        parse_results(@results)
      end
      
      should "reorder the records" do
        expects(:reorder).with([], [1, 2])
        parse_results(@results)
      end
      
      should "add :include if :include was specified" do
        expects(:find).with(:all, :conditions => ["documents.id in (?)", [1, 2]], :include => [:author]).returns [1, 2]
        parse_results(@results, :include => [:author])
      end
    end
    
    context "when the format doesn't request objects" do
      setup do
        @solr_configuration = {:primary_key_field => "pk_id"}
      end

      should "not query the database" do
        expects(:find).never
        parse_results(@results, :format => nil)
      end
      
      should "return just the ids" do
        @results.stubs(:hits).returns([{"pk_id" => 1}, {"pk_id" => 2}])
        assert_equal [1, 2], parse_results(@results, :format => nil).docs
      end
    end
    
    context "with an empty result set" do
      setup do
        @results.stubs(:total_hits).returns(0)
        @results.stubs(:hits).returns([])
      end

      should "return an empty search results set" do
        assert_equal 0, parse_results(@results).total
      end
      
      should "not have any search results" do
        assert_equal [], parse_results(@results).docs
      end
    end
    
    context "with the scores option" do
      setup do
      end
      
      should "add the scores" do
        expects(:add_scores).with([], @results)
        parse_results(@results, :scores => true)
      end
    end
    
  end
  
  context "when reordering results" do
    should "raise an error if arguments don't have the same number of elements" do
      assert_raise(RuntimeError) {reorder([], [1])}
    end
    
    should "reorder the results to match the order of the documents returned by solr" do
      thing1 = stub(:thing1)
      thing1.stubs(:id).returns 5
      thing2 = stub(:thing2)
      thing2.stubs(:id).returns 1
      thing3 = stub(:things3)
      thing3.stubs(:id).returns 3
      things = [thing1, thing2, thing3]
      reordered = reorder(things, [1, 3, 5])
      assert_equal [1, 3, 5], reordered.collect{|thing| thing.id}
    end
  end

  context "When parsing a query" do
    setup do
      ActsAsSolr::Post.stubs(:execute)
      stubs(:solr_type_condition).returns "(type:ParserMethodsTest)"
      @solr_configuration = {:primary_key_field => "id"}
      @configuration = {:solr_fields => nil}
    end
    
    should "set the limit and offset" do
      ActsAsSolr::Post.expects(:execute).with {|request|
        10 == request.to_hash[:rows]
        20 == request.to_hash[:start]
      }
      parse_query "", :limit => 10, :offset => 20
    end
    
    should "set the operator" do
      ActsAsSolr::Post.expects(:execute).with {|request|
        "OR" == request.to_hash["q.op"]
      }
      parse_query "", :operator => :or
    end
    
    should "not execute anything if the query is empty" do
      ActsAsSolr::Post.expects(:execute).never
      parse_query(nil)
    end
    
    should "raise an error if invalid options where specified" do
      assert_raise(RuntimeError) {parse_query "", :invalid => true}
    end
    
    should "add the type" do
      ActsAsSolr::Post.expects(:execute).with {|request|
        request.to_hash[:q].include?("(type:ParserMethodsTest)")
      }
      parse_query ""
    end
    
    should "append the field types for the specified fields" do
      ActsAsSolr::Post.expects(:execute).with {|request|
        request.to_hash[:q].include?("(username_t:Chunky)")
      }
      parse_query "username:Chunky"
    end
    
    should "replace the field types" do
      expects(:replace_types).returns(["active_i:1"])
      ActsAsSolr::Post.expects(:execute).with {|request|
        request.to_hash[:q].include?("active_i:1")
      }
      parse_query "active:1"
    end
    
    should "add score and primary key to field list" do
      ActsAsSolr::Post.expects(:execute).with {|request|
        request.to_hash[:fl] == ('id,score')
      }
      parse_query ""
    end
    
    context "with the order option" do
      should "add the order criteria to the query" do
        ActsAsSolr::Post.expects(:execute).with {|request|
          request.to_hash[:q].include?(";active_t desc")
        }
        parse_query "active:1", :order => "active desc"
      end
    end
    
    context "with facets" do
    end
  end
end