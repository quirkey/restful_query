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
          assert_equal({}, @parser.to_query_hash)
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
          assert_equal @base_query_hash, @parser.to_query_hash
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

      context "with blank values" do
        setup do
          new_parser_from_hash({'isblank' => ''})
        end

        should "return parser object" do
          assert @parser.is_a?(RestfulQuery::Parser)
        end

        should "not include conditions for blank values" do
          assert @parser.conditions_for('created_at')
          assert_nil @parser.conditions_for('isblank')
        end
      end

      context "with map_columns" do
        setup do
          new_parser_from_hash({'section' => 4, '_sort' => 'category-up'}, {:map_columns => {
            'section' => 'section_id',
            'category' => 'category_id'
          }})
        end

        should "return parser object" do
          assert @parser.is_a?(RestfulQuery::Parser)
        end

        should "set the map_columns attribute" do
          assert @parser.map_columns.is_a?(Hash)
        end

        should "map condition column" do
          assert @parser.conditions_for('section')
          assert_equal 'section_id', @parser.conditions_for('section').first.column
        end

        should "map sort column" do
          @sort = @parser.sorts.first
          assert @sort.is_a?(RestfulQuery::Sort)
          assert_equal 'ASC', @sort.direction
          assert_equal 'category_id', @sort.column
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

      context "with sort options" do
        setup do
          new_parser_from_hash({'_sort' => ['created_at-up']}, :sort_options => {:nulls => :first})
        end

        should "return parser object" do
          assert @parser.is_a?(RestfulQuery::Parser)
        end

        should "add sorts to sorts" do
          assert @parser.sorts
          assert_equal 1, @parser.sorts.length
          assert_equal 'created_at ASC NULLS FIRST', @parser.sort_sql
        end
      end

      context "with a default_sort" do
        context "with no sorts defined in the query hash" do
          setup do
            new_parser_from_hash({}, {:default_sort => 'created_at DESC'})
          end

          should "return parser object" do
            assert @parser.is_a?(RestfulQuery::Parser)
          end

          should "have default sort in sorts" do
            assert @parser.sorts
            assert_equal 1, @parser.sorts.length
            assert_equal 'created_at DESC', @parser.sort_sql
          end
        end

        context "with sorts defined in the query hash" do
          setup do
            new_parser_from_hash({'_sort' => 'created_at-up'})
          end

          should "return parser object" do
            assert @parser.is_a?(RestfulQuery::Parser)
          end

          should "have query hash sorts in sorts and not default sort" do
            assert @parser.sorts
            assert_equal 1, @parser.sorts.length
            assert_equal 'created_at ASC', @parser.sort_sql
          end
        end
      end
    end

    context "from an array of conditions" do
      setup do
        @array_of_conditions = [
          {'column' => 'created_at', 'operator' => 'gt', 'value' => '1 week ago'},
          {'column' => 'created_at', 'operator' => 'lt', 'value' => '1 hour ago'},
          {'column' => 'updated_at', 'operator' => 'lt', 'value' => '1 day ago'},
          {'column' => 'title', 'operator' => 'eq', 'value' => 'Test'},
          {'column' => 'other_time', 'operator' => 'gt', 'value' => 'oct 1'},
          {'column'  => 'name', 'value' => 'Aaron'}
        ]
        @parser = RestfulQuery::Parser.new(:conditions => @array_of_conditions)
      end

      should "return parser object" do
        assert @parser.is_a?(RestfulQuery::Parser)
      end

      should "save each condition as a condition object" do
        assert @parser.conditions.is_a?(Array)
        assert_equal 6, @parser.conditions.length
        assert @parser.conditions.first.is_a?(RestfulQuery::Condition)
      end

      should "save condition without operator with default operator" do
        assert @parser.conditions_for(:name)
        assert @parser.conditions_for(:name).first.is_a?(RestfulQuery::Condition)
        assert_equal '=', @parser.conditions_for(:name).first.operator
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
          assert_equal @base_query_hash.keys.length + 1, @conditions.length
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
          assert_equal @base_query_hash.keys.length + 2, @conditions.length
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

      context "to_query_hash" do
        context "with no altering" do
          setup do
            @query_hash = @parser.to_query_hash
          end

          should "return hash" do
            assert @query_hash.is_a?(Hash)
          end

          should "return initial query hash" do
            assert_equal({'gt' => '1 week ago', 'lt' => '1 hour ago'}, @query_hash['created_at'])
          end
        end

        context "with altered sorts" do
          setup do
            @parser.set_sort('title', 'up')
            @parser.set_sort('created_at', 'down')
            @query_hash = @parser.to_query_hash
          end

          should "include unaltered sort conditions" do
            assert_equal({'gt' => '1 week ago', 'lt' => '1 hour ago'}, @query_hash['created_at'])
          end

          should "include altered sorts" do
            assert_equal(['title-asc','created_at-desc'], @query_hash['_sort'])
          end
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

        context "set_sort" do
          context "with an existing sort" do
            setup do
              @parser.set_sort('title','up')
            end

            should "not add new sort" do
              assert_equal 2, @parser.sorts.length
            end

            should "update sort direction" do
              assert_equal 'ASC', @parser.sort('title').direction
            end
          end

          context "with direction: nil" do
            setup do
              @parser.set_sort('title', nil)
            end

            should "remove sort" do
              assert_equal 1, @parser.sorts.length
              assert !@parser.sorted_by?('title')
            end
          end

          context "with a new sort" do
            setup do
              @parser.set_sort('name', 'down')
            end

            should "add sort to sorts" do
              assert_equal 3, @parser.sorts.length
            end

            should "set sort direction" do
              assert_equal 'DESC', @parser.sort('name').direction
            end
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
