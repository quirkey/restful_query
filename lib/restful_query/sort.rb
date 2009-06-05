module RestfulQuery
  class InvalidDirection < Error; end
  
  class Sort
    include Comparable
    
    attr_reader :column, :direction
    
    DIRECTIONS = {
      'up' => 'ASC',
      'asc' => 'ASC',
      'ASC' => 'ASC',
      'down' => 'DESC',
      'desc' => 'DESC',
      'DESC' => 'DESC'
    }.freeze
    
    
    def initialize(column, direction)
      self.column    = column
      self.direction = direction
    end
    
    def self.parse(sort_string, split_on = /-|\ /)
      return unless sort_string
      column, direction = sort_string.split(split_on)
      new(column, direction)
    end
    
    def column=(column)
      @column = column.to_s
    end
    
    def direction=(direction)
      @direction = DIRECTIONS[direction.to_s]
      raise(InvalidDirection, "'#{direction}' is not a valid order direction") unless @direction
    end
    
    def reverse_direction
      direction == 'ASC' ? 'DESC' : 'ASC'
    end
    
    def ==(other)
      return false unless other.is_a?(Sort)
      column == other.column && direction == other.direction
    end
    
    # Makes a roundabout for directions nil -> desc -> asc -> nil
    def self.next_direction(current_direction)
      case current_direction.to_s.downcase
      when 'desc'
        'asc'
      when 'asc'
        nil
      else
        'desc'
      end
    end
    
    def next_direction
      self.class.next_direction(direction)
    end
    
    def to_s(join = '-')
      "#{column}#{join}#{direction.downcase}"
    end
            
    def to_sql
      "#{column} #{direction}"
    end
  end
end