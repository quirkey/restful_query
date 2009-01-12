module RestfulQuery
  class InvalidDirection < Error; end
  
  class Order
    attr_reader :column, :direction
    
    DIRECTIONS = {
      'up' => 'ASC',
      'asc' => 'ASC',
      'down' => 'DESC',
      'desc' => 'DESC'
    }.freeze
    
    
    def initialize(column, direction)
      self.column    = column
      self.direction = direction
    end
    
    def column=(column)
      @column = column.to_s
    end
    
    def direction=(direction)
      @direction = DIRECTIONS[direction.to_s]
      raise(InvalidDirection, "'#{direction}' is not a valid order direction") unless @direction
    end
    
    def to_sql
      "#{column} #{direction}"
    end
  end
end