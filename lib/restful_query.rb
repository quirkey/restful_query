$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

begin
  require 'rubygems'
  require 'chronic'
  unless defined?(ActiveSupport)
    require 'active_support'
  end
rescue LoadError
  warn 'In order to use the time parsing functinalities you must install the Chronic gem: sudo gem install chronic'
end

module RestfulQuery
  VERSION = '0.1.0'
end


%w{condition parser can_query}.each do |lib|
  require File.join(File.dirname(__FILE__),"restful_query","#{lib}.rb")
end
