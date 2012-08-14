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

          scope_meth = self.respond_to?(:where) ? :scope : :named_scope

          send(scope_meth, :restful_query, lambda {|query_hash|
            query_hash = {} if query_hash.blank? || query_hash.empty?
            parser = self.restful_query_parser(query_hash)
            query_hash = {}
            query_hash[:conditions] = parser.to_conditions_array if parser.has_conditions?
            query_hash[:include]    = @include if @include && !@include.empty?
            query_hash[:order]      = parser.sort_sql if parser.has_sort?
            logger.info 'Rest query:' + query_hash.inspect
            query_hash
          })
        end
      end

      def can_query?
        @can_query
      end
    end

  end
end
