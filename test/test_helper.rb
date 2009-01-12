require 'test/unit'
require 'rubygems'
require 'shoulda'

require File.join(File.dirname(__FILE__), '..', 'lib','restful_query.rb')


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