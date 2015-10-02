require File.join(File.dirname(__FILE__), '..', '..', 'restful_query.rb')

module RestfulQuery
  class Sort
    
    def to_sequel
      column.to_sym.send(direction.downcase)
    end
    
  end

  class Condition
    def column
      DB.quote_identifier(@column)
    end
  end
end

module Sequel
  class Dataset
        
    def restful_query(query_hash, options = {})
      parser = RestfulQuery::Parser.new(query_hash, options = {})
      collection = self
      collection = collection.filter(*parser.to_conditions_array) if parser.has_conditions?
      collection = collection.order(*parser.sorts.collect {|s| s.to_sequel }) if parser.has_sort?
      collection
    end
  end
  
end