require 'test_helper'

class RestfulQueryOrderTest < Test::Unit::TestCase

  context "Order" do
    context "initializing" do
      context "with valid column and direction" do
        setup do
          @order = RestfulQuery::Order.new(:attribute, 'up')
        end
        
        should "save column name as string" do
          assert_equal 'attribute', @order.column
        end
        
        should "interpret direction" do
          assert_equal 'ASC', @order.direction
        end
      end
      
      context "with an invalid direction" do
        should "raise error" do
          assert_raise(RestfulQuery::InvalidDirection) do
            RestfulQuery::Order.new('column', 'blarg')
          end
        end
      end
      
    end
    
    context "to_sql" do
      should "join the column and attribute" do
        @order = RestfulQuery::Order.new(:attribute, 'down')
        assert_equal 'attribute DESC', @order.to_sql
      end
    end
    
  end
  
end
