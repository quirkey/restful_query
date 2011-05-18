require File.join(File.expand_path(File.dirname(__FILE__)),'..','restful_query.rb')

ActiveRecord::Base.send(:include, RestfulQuery::CanQuery)
