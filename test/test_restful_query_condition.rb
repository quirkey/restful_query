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
      
      context "with a value of ':nil'" do
        setup do
          @condition = RestfulQuery::Condition.new('created_at', ':nil')
        end
        
        should "convert value to true nil" do
          assert_equal(nil, @condition.value)
        end
      end
      
      context "with a value of ':true'" do
        setup do
          @condition = RestfulQuery::Condition.new('created_at', ':true')
        end
        
        should "convert value to true true" do
          assert_equal(true, @condition.value)
        end
      end
      
      context "with a value of ':blank'" do
        setup do
          @condition = RestfulQuery::Condition.new('created_at', ':blank')
        end
        
        should "convert value to true true" do
          assert_equal('', @condition.value)
        end
      end
      
      context "with the IN operator" do
        setup do
          @condition = RestfulQuery::Condition.new('year', '1995,2005,2006', 'in')
        end
        
        should "assign the operator" do
          assert_equal 'IN', @condition.operator
        end
        
        should "split values by the delimiter option" do
          assert_equal ['1995', '2005', '2006'], @condition.value
        end
        
        should "include parens in placeholder" do
          assert_equal ["year IN (?)", ['1995', '2005', '2006']], @condition.to_condition_array
        end
        
        context "when the value is already an array" do
          setup do
            @condition = RestfulQuery::Condition.new('year', ['1995', '2005', '2006'], 'in')
          end
          
          should "not resplit the value" do
            assert_equal ['1995', '2005', '2006'], @condition.value
          end
        end
      end
      
      context "with the NOT IN operator" do
        setup do
          @condition = RestfulQuery::Condition.new('year', '1995|2005|2006', 'notin', :delimiter => '|')
        end
        
        should "assign the operator" do
          assert_equal 'NOT IN', @condition.operator
        end
        
        should "split values by delimiter option" do
          assert_equal ['1995', '2005', '2006'], @condition.value
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
