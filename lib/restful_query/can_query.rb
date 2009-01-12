module RestfulQuery
  module CanQuery
   
    def self.included(klass)
      klass.extend MacroMethods
    end

    module MacroMethods
      def can_query(options = {})
        @include       = options.delete(:include) || []
        @query_options = options
        @can_query     = true
        module_eval do
          named_scope :restful_query, lambda {|query_hash| 
            conditions_array = RestfulQuery::Parser.new(query_hash, @query_options).to_conditions_array 
            logger.info 'Rest query:' + conditions_array.inspect
            {:conditions => conditions_array, :include => @include}
          }
        end
      end
      
      def can_query?
        @can_query
      end
    end
    
  end
end