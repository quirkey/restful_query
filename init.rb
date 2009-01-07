require 'restful_query'

ActiveRecord::Base.send(:include, RestfulQuery::CanQuery)