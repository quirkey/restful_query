require "helper"

class RestfulQuery::SortTest < Minitest::Test

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

      context "with extra options" do
        setup do
          @sort = RestfulQuery::Sort.new(:attribute, 'up', :nulls => :first)
        end

        should "save column name as string" do
          assert_equal 'attribute', @sort.column
        end

        should "interpret direction" do
          assert_equal 'ASC', @sort.direction
        end

        should "add nulls option" do
          assert_equal :first, @sort.options[:nulls]
        end
      end

      context "with an invalid direction" do
        should "raise error" do
          assert_raises(RestfulQuery::InvalidDirection) do
            RestfulQuery::Sort.new('column', 'blarg')
          end
        end
      end

    end

    context "parse" do
      context "with a query hash like condition" do
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

      context "with a standard SQL like condition" do
        setup do
          @sort = RestfulQuery::Sort.parse('long_name_attribute DESC NULLS LAST')
        end

        should "return sort object" do
          assert @sort.is_a?(RestfulQuery::Sort)
        end

        should "set column and direction" do
          assert_equal 'long_name_attribute', @sort.column
          assert_equal 'DESC', @sort.direction
        end

        should "set other options" do
          assert_equal :last, @sort.options[:nulls]
        end
      end
    end

    context "to_sql" do
      should "join the column and attribute" do
        @sort = RestfulQuery::Sort.new(:attribute, 'down')
        assert_equal 'attribute DESC', @sort.to_sql
      end

      should "parse null option" do
        @sort = RestfulQuery::Sort.new(:attribute, 'down', :nulls => :last)
        assert_equal 'attribute DESC NULLS LAST', @sort.to_sql
      end
    end

  end

end
