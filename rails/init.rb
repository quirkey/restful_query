require File.join(File.dirname(__FILE__),'..','lib','restful_query.rb')
require File.join(File.dirname(__FILE__),'..','lib','restful_query', 'can_query.rb')

ActiveRecord::Base.send(:include, RestfulQuery::CanQuery)