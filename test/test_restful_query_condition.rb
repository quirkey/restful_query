require 'test_helper'

class RestfulQueryConditionTest < Test::Unit::TestCase

  context "Condition" do

    context "initializing" do
      context "with column, value, operator" do
        setup do
          @condition = RestfulQuery::Condition.new('created_at', '1 week ago', '>')
        end

        should "save column" do
          assert_equal 'created_at', @condition.column
        end

        should "save value" do
          assert_equal '1 week ago', @condition.value
        end

        should "save operator as string" do
          assert_equal '>', @condition.operator
        end

      end

      context "with no operator" do
        setup do
          @condition = RestfulQuery::Condition.new('created_at', '1 week ago')
        end

        should "assume =" do
          assert_equal '=', @condition.operator
        end

      end

      context "with an operator as a string" do
        setup do
          @condition = RestfulQuery::Condition.new('created_at', '1 week ago', 'gteq')
        end

        should "translate string to operator" do
          assert_equal '>=', @condition.operator
        end

      end

      context "with chronic => true" do
        setup do
          @condition = RestfulQuery::Condition.new('created_at', '1 week ago', 'gteq', :chronic => true)
        end

        should "save option to options" do
          assert @condition.options[:chronic]
        end

        should "parse value with chronic" do
          assert_equal(1.week.ago.to_s, @condition.value.to_s)
        end
      end
    end


    context "a Condition" do
      setup do
        @condition = RestfulQuery::Condition.new('title', 'Bossman', 'lt')
      end
      
      context "with operator = like to condition array" do
        setup do
          @condition = RestfulQuery::Condition.new('title', 'Bossman', 'like')
          @to_condition_array = @condition.to_condition_array
        end
        
        should "wrap value with %" do
          assert_equal "%Bossman%", @to_condition_array[1]
        end
        
        should "translate operator to LIKE" do
          assert_equal("title LIKE ?", @to_condition_array[0])
        end
        
      end
      
      context "to_condition_array" do
        setup do
          @to_condition = @condition.to_condition_array
        end

        should "return array" do
          assert @to_condition.is_a?(Array)
        end

        should "have conditional string first" do
          assert_equal 'title < ?', @to_condition[0]
        end

        should "have value as [1]" do
          assert_equal @condition.value, @to_condition[1]
        end
      end
    
      context "to_hash" do
        should "return hash like params" do
          assert_equal({'title' => {'lt' => 'Bossman'}}, @condition.to_hash)
        end
      end
    end
  end

end
