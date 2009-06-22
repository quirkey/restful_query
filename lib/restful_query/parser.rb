module RestfulQuery
  class Parser
    attr_reader :query, :exclude_columns, :integer_columns, :options

    def initialize(query, options = {})
      @options         = options || {}
      @exclude_columns = options[:exclude_columns] ? [options.delete(:exclude_columns)].flatten.collect {|c| c.to_s } : []
      @integer_columns = options[:integer_columns] ? [options.delete(:integer_columns)].flatten.collect {|c| c.to_s } : []
      @default_sort    = options[:default_sort] ? [Sort.parse(options[:default_sort])] : []
      @single_sort     = options[:single_sort] || false
      @query           = (query || {}).dup
      @default_join    = @query.delete(:join) || :and
      extract_sorts_from_conditions
      map_conditions
    end

    def conditions
      conditions_hash.values.flatten
    end
    
    def has_conditions?
      !conditions.empty?
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
    
    def to_query_hash
      hash = @query
      hash['_sort'] = sorts.collect {|s| s.to_s } unless sorts.empty?
      hash
    end
        
    def self.sorts_from_hash(sorts)
      sort_conditions = [sorts].flatten.compact
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
    
    def sorted_columns
      sorts.collect {|s| s.column }
    end
    
    def sorted_by?(column)
      sorted_columns.include?(column.to_s)
    end
    
    def sort(column)
      sorts.detect {|s| s && s.column == column.to_s }
    end
    
    def set_sort(column, direction)
      if new_sort = self.sort(column)
        if direction.nil?
          self.sorts.reject! {|s| s.column == column.to_s }
        else
          new_sort.direction = direction
        end
      else
        new_sort = Sort.new(column, direction)
        self.sorts << new_sort
      end
      new_sort
    end
    
    def clear_default_sort!
      @sorts.reject! {|s| s == @default_sort.first }
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
      @sorts = self.class.sorts_from_hash(@query.delete('_sort'))
      @sorts = @default_sort if @sorts.empty?
    end

    def map_conditions
      conditions = query.delete(:conditions) || query
      if conditions.is_a?(Hash)
        conditions_array = []
        conditions.each do |column, hash_conditions|
          if hash_conditions.is_a?(Hash)
            hash_conditions.each do |operator, value|
              conditions_array << {'column' => column, 'operator' => operator, 'value' => value}
            end
          else
            conditions_array << {'column' => column, 'value' => hash_conditions}
          end
        end
        conditions = conditions_array
      end
      # with a normalized array of conditions
      conditions.each do |condition|
        column, operator, value = condition['column'], condition['operator'] || 'eq', condition['value']
        unless exclude_columns.include?(column.to_s)
          condition_options = {}
          condition_options[:chronic] = true if chronic_columns.include?(column.to_s)
          condition_options[:integer] = true if integer_columns.include?(column.to_s)
          add_condition_for(column, Condition.new(column, value, operator, condition_options))
        end
      end
    end
     
  end
end