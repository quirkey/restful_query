module RestfulQuery
  class InvalidOperator < Error; end;
  
  class Condition
    attr_reader :column, :value, :operator, :options
    
    OPERATOR_MAPPING = {
      'lt'   => '<',
      'gt'   => '>',
      'gteq' => '>=',
      'lteq' => '<=',
      'eq'   => '=',
      'neq'  => '!=',
      'is'   => 'IS',
      'not'  => 'IS NOT',
      'like' => 'LIKE'
    }.freeze
      
    REVERSE_OPERATOR_MAPPING = {
      '<'       => 'lt', 
      '>'       => 'gt',  
      '>='      => 'gteq',
      '<='      => 'lteq',
      '='       => 'eq',
      '!='      => 'neq',
      'IS'      => 'is',
      'IS NOT'  => 'not',
      'LIKE'    => 'like'
    }.freeze
    
    CONVERTABLE_VALUES = {
      ':true'  => true,
      ':false' => false,
      ':nil'   => nil,
      ':null'  => nil
    }.freeze
    
    
    def initialize(column, value, operator = '=', options = {})
      @options = {}
      @options = options if options.is_a?(Hash)
      self.column   = column
      self.operator = operator
      self.value    = value
    end
    
    def map_operator(operator_to_look_up, reverse = false)
      mapping = reverse ?  REVERSE_OPERATOR_MAPPING.dup : OPERATOR_MAPPING.dup
      return operator_to_look_up if mapping.values.include?(operator_to_look_up)
      found = mapping[operator_to_look_up.to_s]
    end
 
    def operator=(operator)
      @operator = map_operator(operator)
      raise(RestfulQuery::InvalidOperator, "#{@operator} is not a valid operator") unless @operator
    end
      
    def column=(column)
      @column = column.to_s
    end
    
    def value=(value)
      @value = parse_value(value)
    end
    
    def to_hash
      {column => {map_operator(operator, true) => value}}
    end
    
    def to_condition_array
      ["#{column} #{operator} ?", value]
    end
    
    protected
    def parse_value(value)
      if operator == 'LIKE' 
        "%#{value}%"
      elsif options[:integer]
        value.to_i
      elsif options[:chronic]
        Chronic.parse(value.to_s)
      elsif value =~ /^\:/ && CONVERTABLE_VALUES.has_key?(value)
        CONVERTABLE_VALUES[value]
      else
        value
      end
    end
    
  end
end