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
          def self.restful_query_parser(query_hash, options = {})
            RestfulQuery::Parser.new(query_hash, @query_options.merge(options))
          end
          
          named_scope :restful_query, lambda {|query_hash| 
            parser = self.restful_query_parser(query_hash)
            logger.info 'Rest query:' + conditions_array.inspect
            query_hash = {:conditions => parser.to_conditions_array}
            query_hash[:include] = @include if @include && !@include.empty?
            query_hash[:order]   = parser.sort_sql if parser.has_sort?
            query_hash
          }
        end
      end
      
      def can_query?
        @can_query
      end
    end
    
  end
end