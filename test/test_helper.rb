require 'test/unit'
require 'rubygems'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.expand_path(File.dirname(__FILE__)), '..'))
require 'lib/restful_query'


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
