require File.join(File.expand_path(File.dirname(__FILE__)),'..','lib','restful_query.rb')

ActiveRecord::Base.send(:include, RestfulQuery::CanQuery)
