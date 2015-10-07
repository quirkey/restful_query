module RestfulQuery
  class InvalidOperator < Error; end;
  
  class Condition
    attr_reader :value, :operator, :options
    
    OPERATOR_MAPPING = {
      'lt'    => '<',
      'gt'    => '>',
      'gteq'  => '>=',
      'lteq'  => '<=',
      'eq'    => '=',
      'neq'   => '!=',
      'is'    => 'IS',
      'not'   => 'IS NOT',
      'like'  => 'LIKE',
      'in'    => 'IN',
      'notin' => 'NOT IN'
    }.freeze
    
    CONVERTABLE_VALUES = {
      ':true'  => true,
      ':false' => false,
      ':nil'   => nil,
      ':null'  => nil,
      ':blank' => '',
      ':empty' => ''
    }.freeze
    
    ENGLISH_OPERATOR_MAPPING = {
      'Less than'                => 'lt',
      'Greater than'             => 'gt',
      'Less than or equal to'    => 'lteq',
      'Greater than or equal to' => 'gteq',
      'Equal to'                 => 'eq',
      'Not equal to'             => 'neq',
      'Is'                       => 'is',
      'Is not'                   => 'not',
      'Like'                     => 'like',
      'In'                       => 'in',
      'Not in'                   => 'notin'
    }.freeze
    
    
    def initialize(column, value, operator = '=', options = {})
      @options = {}
      self.options  = options if options.is_a?(Hash)
      self.column   = column
      self.operator = operator
      self.value    = value
    end
    
    def map_operator(operator_to_look_up, reverse = false)
      mapping = reverse ?  OPERATOR_MAPPING.dup.invert : OPERATOR_MAPPING.dup
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
    
    def options=(options)
      options.each {|k, v| @options[k.to_sym] = v }
    end
    
    def to_hash
      {column => {map_operator(operator, true) => value}}
    end
    
    def to_condition_array
      ["#{column} #{operator} #{placeholder}", value]
    end

    def column
      ActiveRecord::Base.connection.quote_column_name(@column)
    end
    
    def placeholder
      if ['IN', 'NOT IN'].include?(operator)
        '(?)'
      else
        '?'
      end
    end
    
    protected
    def parse_value(value)
      if operator == 'LIKE' 
        "%#{value}%"
      elsif ['IN', 'NOT IN'].include?(operator) && !value.is_a?(Array)
        value.split(options[:delimiter] || ',')
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