$LOAD_PATH.unshift(File.join(File.expand_path(File.dirname(__FILE__)), "../lib"))

require "rubygems"
require "minitest/autorun"
require "shoulda-context"

require "restful_query"


unless defined?(ActiveRecord)
  module ActiveRecord
    class Base
      class << self
        attr_accessor :pluralize_table_names

        def protected_attributes
          []
        end

        def named_scope(name, options = {})
        end
      end
      self.pluralize_table_names = true

      include RestfulQuery::CanQuery
    end
  end
end

class ClassWithQuery < ActiveRecord::Base
  can_query
end

class ClassWithoutQuery < ActiveRecord::Base

end
