require 'test_helper'

class RestfulQueryParserTest < Test::Unit::TestCase

  context "Parser" do
    setup do
      @base_query_hash = {'created_at' => {'gt' => '1 week ago', 'lt' => '1 hour ago'}, 'updated_at' => {'lt' => '1 day ago'}, 'title' => {'eq' => 'Test'}, 'other_time' => {'gt' => 'oct 1'}, 'name' => 'Aaron'}
    end

    context "from_hash" do

      context "without hash" do
        setup do
          @parser = RestfulQuery::Parser.new(nil)
        end

        should "return Parser object" do
          assert @parser.is_a?(RestfulQuery::Parser)
        end

        should "have a blank hash for query hash" do
          assert_equal({}, @parser.query_hash)
        end
      end

      context "with a hash of columns and operations" do
        setup do
          new_parser_from_hash
        end

        should "return parser object" do
          assert @parser.is_a?(RestfulQuery::Parser)
        end

        should "save hash to query_hash" do
          assert_equal @base_query_hash, @parser.query_hash.to_hash
        end

        should "save each condition as a condition object" do
          assert @parser.conditions.is_a?(Array)
          assert @parser.conditions.first.is_a?(RestfulQuery::Condition)
        end

        should "save condition without operator with default operator" do
          assert @parser.conditions_for(:name)
          assert @parser.conditions_for(:name).first.is_a?(RestfulQuery::Condition)
          assert_equal '=', @parser.conditions_for(:name).first.operator
        end

      end

      context "with exclude columns" do
        setup do
          new_parser_from_hash({}, :exclude_columns => [:other_time,'name'])
        end

        should "return parser object" do
          assert @parser.is_a?(RestfulQuery::Parser)
        end

        should "exclude columns from conditions" do
          assert @parser.conditions_for('created_at')
          assert_nil @parser.conditions_for('other_time')
          assert_nil @parser.conditions_for(:name)
        end

      end

      context "with chronic => true" do
        setup do
          new_parser_from_hash({}, :chronic => true)
        end

        should "return parser object" do
          assert @parser.is_a?(RestfulQuery::Parser)
        end

        should "parse created at and updated with chronic" do
          assert_equal Chronic.parse('1 week ago').to_s, @parser.conditions_for(:created_at).first.value.to_s
          assert_equal Chronic.parse('1 day ago').to_s, @parser.conditions_for(:updated_at).first.value.to_s
        end

      end

      context "with chronic => []" do
        setup do
          new_parser_from_hash({}, :chronic => [:other_time])
        end

        should "return parser object" do
          assert @parser.is_a?(RestfulQuery::Parser)
        end

        should "parse selected attributes in array with chronic" do
          assert_equal Chronic.parse('oct 1').to_s, @parser.conditions_for(:other_time).first.value.to_s
        end

        should "not parse created at/updated at if not specified" do
          assert_not_equal Chronic.parse('1 week ago').to_s, @parser.conditions_for(:created_at).first.value.to_s
          assert_not_equal Chronic.parse('1 day ago').to_s, @parser.conditions_for(:updated_at).first.value.to_s
        end
      end

      context "with sort as a single string" do
        setup do
          new_parser_from_hash({'_sort' => 'created_at-up'})
        end

        should "return parser object" do
          assert @parser.is_a?(RestfulQuery::Parser)
        end

        should "parse sort string" do
          @sort = @parser.sorts.first 
          assert @sort.is_a?(RestfulQuery::Sort)
          assert_equal 'ASC', @sort.direction
          assert_equal 'created_at', @sort.column
        end

        should "add sort to sorts" do
          assert @parser.sorts
          assert_equal 1, @parser.sorts.length
        end

      end

      context "with sort as an array of strings" do
        setup do
          new_parser_from_hash({'_sort' => ['created_at-up','title-desc']})
        end

        should "return parser object" do
          assert @parser.is_a?(RestfulQuery::Parser)
        end

        should "add sorts to sorts" do
          assert @parser.sorts
          assert_equal 2, @parser.sorts.length
          @parser.sorts.each do |sort|
            assert sort.is_a?(RestfulQuery::Sort)
          end
        end

      end
    end

    context "a loaded parser" do
      setup do
        new_parser_from_hash
      end

      context "conditions" do
        setup do
          @conditions = @parser.conditions
        end

        should "return array of all conditions objects" do
          assert @conditions.is_a?(Array)
          @conditions.each do |condition|
            assert condition.is_a?(RestfulQuery::Condition)
          end
        end

        should "include conditions for every attribute" do
          assert_equal @base_query_hash.keys.length, @conditions.length
        end
      end

      context "conditions_for" do
        should "return nil for columns without conditions" do
          assert_nil @parser.conditions_for(:blah)
        end

        should "return array of conditions for column that exists" do
          @conditions = @parser.conditions_for(:created_at)
          assert @conditions.is_a?(Array)
          @conditions.each do |condition|
            assert condition.is_a?(RestfulQuery::Condition)
            assert_equal 'created_at', condition.column
          end
        end

      end

      context "to conditions array" do
        setup do
          @conditions = @parser.to_conditions_array
        end

        should "return array" do
          assert @conditions.is_a?(Array)
        end

        should "first element should be a condition string" do
          assert @conditions[0].is_a?(String)
        end

        should "include operators for all querys" do
          assert_match(/(([a-z_]) (\<|\>|\=|\<\=|\>\=) \? AND)+/,@conditions[0])
        end

        should "join query hash with AND" do
          assert_match(/AND/,@conditions[0])
        end

        should "include values for each conditions" do
          assert_equal @base_query_hash.keys.length + 1, @conditions.length
        end

      end

      context "to conditions with :or" do
        setup do
          @conditions = @parser.to_conditions_array(:or)
        end

        should "join query hash with OR" do
          assert_match(/(([a-z_]) (\<|\>|\=|\<\=|\>\=) \? OR)+/,@conditions[0])
        end
      end
      
      context "sorts" do
        setup do
          new_parser_from_hash({'_sort' => ['title-down', 'updated_at-asc']})
          @sorts = @parser.sorts 
        end
        
        should "return an array of sort objects" do
          assert @sorts
          assert_equal 2, @sorts.length
          @sorts.each do |sort|
            assert sort.is_a?(RestfulQuery::Sort)
          end
        end
        
        context "sorted_columns" do
          should "return an array of columns" do
            @sorted_columns = @parser.sorted_columns
            assert @sorted_columns.is_a?(Array)
            assert @sorted_columns.include?('title')
          end
        end
        
        context "sorted_by?" do
          should "return true if column is sorted" do
            assert @parser.sorted_by?('title')
          end
          
          should "return false if column is not sorted" do
            assert !@parser.sorted_by?('created_at')
          end
        end
        
        context "sort()" do
          should "return Sort object if column is sorted" do
            sort = @parser.sort('title')
            assert sort.is_a?(RestfulQuery::Sort)
            assert_equal 'title', sort.column
          end
          
          should "return nil if col" do
            assert_nil @parser.sort('created_at')
          end
        end
      end
      

      context "sort_sql" do
        should "join order with ," do
          new_parser_from_hash({'_sort' => ['title-down', 'updated_at-asc']})
          assert_equal 'title DESC, updated_at ASC', @parser.sort_sql
        end
      end

    end

  end

  protected
  def new_parser_from_hash(params = {}, options = {})
    @parser = RestfulQuery::Parser.new(@base_query_hash.merge(params), options)
  end
end
