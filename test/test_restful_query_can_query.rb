require File.dirname(__FILE__) + '/test_helper.rb'

class TestRestfulQueryCanQuery < Test::Unit::TestCase

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
