require "helper"

class RestfulQuery::CanQueryTest < Minitest::Test

  context "CanQuery" do
    context "A class with the can_query macro" do
      should "can_query?" do
        assert ClassWithQuery.can_query?
      end
    end

    context "A class without the can_query macro" do
      should "not can_query?" do
        assert !ClassWithoutQuery.can_query?
      end
    end

  end

end
