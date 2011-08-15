module RestfulQuery
  class InvalidDirection < Error; end

  class Sort
    include Comparable

    attr_reader :column, :direction, :options

    DIRECTIONS = {
      'up' => 'ASC',
      'asc' => 'ASC',
      'ASC' => 'ASC',
      'down' => 'DESC',
      'desc' => 'DESC',
      'DESC' => 'DESC'
    }.freeze


    def initialize(column, direction, options = {})
      self.column    = column
      self.direction = direction
      self.options = options
    end

    def self.parse(sort_string, split_on = /\-|\ /)
      return unless sort_string
      column, direction, options = sort_string.split(split_on, 3)
      new(column, direction, options)
    end

    def column=(column)
      @column = column.to_s
    end

    def direction=(direction)
      @direction = DIRECTIONS[direction.to_s]
      raise(InvalidDirection, "'#{direction}' is not a valid order direction") unless @direction
    end

    def options=(options)
      @options = if options.is_a?(String)
        opts = {}
        options.split(/ /).each_slice(2) do |k|
          k.map! {|v| v.to_s.downcase.to_sym }
          opts[k[0]] = k[1]
        end
        opts
      else
        options || {}
      end
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
      s = "#{column}#{join}#{direction.downcase}"
      s << " #{options.inspect}" unless options.empty?
      s
    end

    def to_sql
      sql = "#{column} #{direction}"
      unless options.empty?
        sql << ' ' << options.to_a.flatten.collect {|k| k.to_s.upcase }.join(' ')
      end
      sql
    end
  end
end
