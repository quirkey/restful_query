require 'test_helper'

class RestfulQuerySortTest < Test::Unit::TestCase

  context "Sort" do
    context "initializing" do
      context "with valid column and direction" do
        setup do
          @sort = RestfulQuery::Sort.new(:attribute, 'up')
        end
        
        should "save column name as string" do
          assert_equal 'attribute', @sort.column
        end
        
        should "interpret direction" do
          assert_equal 'ASC', @sort.direction
        end
      end
      
      context "with an invalid direction" do
        should "raise error" do
          assert_raise(RestfulQuery::InvalidDirection) do
            RestfulQuery::Sort.new('column', 'blarg')
          end
        end
      end
      
    end
    
    context "parse" do
      setup do
        @sort = RestfulQuery::Sort.parse('long_name_attribute-down')
      end
      
      should "return sort object" do
        assert @sort.is_a?(RestfulQuery::Sort)
      end
      
      should "set column and direction" do
        assert_equal 'long_name_attribute', @sort.column
        assert_equal 'DESC', @sort.direction
      end
    end
    
    context "to_sql" do
      should "join the column and attribute" do
        @sort = RestfulQuery::Sort.new(:attribute, 'down')
        assert_equal 'attribute DESC', @sort.to_sql
      end
    end
    
  end
  
end
