$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require "active_support"
require "chronic"

module RestfulQuery
  VERSION = "0.4.0"

  class Error < RuntimeError; end
end

require "restful_query/can_query"

require "restful_query/condition"
require "restful_query/sort"
require "restful_query/parser"
