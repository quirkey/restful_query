$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

begin
  require 'chronic'
  unless defined?(ActiveSupport)
    require 'active_support'
  end
rescue LoadError
  warn 'In order to use the time parsing functionalities you must install the Chronic gem: sudo gem install chronic'
end

module RestfulQuery
  VERSION = '0.3.0'
  
  class Error < RuntimeError; end
end


%w{condition sort parser}.each do |lib|
  require File.join("restful_query","#{lib}.rb")
end
