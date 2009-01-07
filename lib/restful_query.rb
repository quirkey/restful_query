begin
  require 'rubygems'
  require 'chronic'
  require 'activesupport'
rescue LoadError
  warn 'In order to use the time parsing functinalities you must install the Chronic gem: sudo gem install chronic'
end


%w{condition parser can_query}.each do |lib|
  require File.join(File.dirname(__FILE__),"restful_query","#{lib}.rb")
end