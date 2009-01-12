module RestfulQuery
  class Parser
    attr_reader :query_hash, :exclude_columns, :integer_columns, :options

    def initialize(query_hash, options = {})
      @options         = options || {}
      @exclude_columns = options[:exclude_columns] ? [options.delete(:exclude_columns)].flatten.collect {|c| c.to_s } : []
      @integer_columns = options[:integer_columns] ? [options.delete(:integer_columns)].flatten.collect {|c| c.to_s } : []
      @query_hash      = query_hash || {}
      @default_join    = @query_hash.delete(:join) || :and
      extract_sorts_from_conditions
      map_hash_to_conditions
    end

    def conditions
      conditions_hash.values.flatten
    end

    def conditions_for(column)
      conditions_hash[column.to_s]
    end

    def to_conditions_array(join = nil)
      join ||= @default_join
      join_string = (join == :or) ? ' OR ' : ' AND '
      conditions_string = []
      conditions_values = []
      conditions.each do |c| 
        ca = c.to_condition_array
        conditions_string << ca[0]
        conditions_values << ca[1]
      end
      conditions_values.unshift(conditions_string.join(join_string))
    end
    
    def self.sorts_from_hash(sorts)
      sort_conditions = [sorts].flatten
      sort_conditions.collect {|c| Sort.parse(c) }
    end
    
    def sort_sql
      @sorts.collect {|s| s.to_sql }.join(', ')
    end
    
    def has_sort?
      !sorts.empty?
    end
    
    def sorts
      @sorts ||= []
    end

    protected
    def add_condition_for(column, condition)
      conditions_hash[column.to_s] ||= []
      conditions_hash[column.to_s] << condition
    end

    def conditions_hash
      @conditions_hash ||= {}
    end

    def chronic_columns
      if chronic = options[:chronic]
        chronic.is_a?(Array) ? chronic.collect {|c| c.to_s } : ['created_at', 'updated_at']
      else
        []
      end
    end
    
    def extract_sorts_from_conditions
      @sorts = self.class.sorts_from_hash(@query_hash.delete('_sort'))
    end

    def map_hash_to_conditions
      @query_hash.each do |column, hash_conditions|
        unless exclude_columns.include?(column.to_s)
          condition_options = {}
          condition_options[:chronic] = true if chronic_columns.include?(column.to_s)
          condition_options[:integer] = true if integer_columns.include?(column.to_s)
          if hash_conditions.is_a?(Hash)
            hash_conditions.each do |operator, value|
              add_condition_for(column, Condition.new(column, value, operator, condition_options))
            end
          else
            add_condition_for(column, Condition.new(column, hash_conditions, '=', condition_options))
          end
        end
      end
    end

  end
end