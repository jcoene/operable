module Operable
  module Operations

    # Add or subtract one method from another
    #
    # method - name of method to perform, as a symbol ( :+ or :- )
    # other - other object to operate with
    #
    # Returns the resulting object
    def add_or_subtract(method, other)
      self.class.new.tap do |o|
        operable_values.each do |k,v|
          o.send("#{k}=", (v || 0).send(method, (other.send(k) || 0)))
          # o[k] = (v || 0).send(method, (other[k] || 0))
        end
      end
    end

    def +(other)
      add_or_subtract(:+, other)
    end

    def -(other)
      add_or_subtract(:-, other)
    end

    # Multiply or divide values of this object by another
    #
    # Returns a new object
    def multiply_or_divide(method, by)
      self.class.new.tap do |o|
        operable_values.each do |k,v|
          o.send("#{k}=", (v || 0).send(method, by))
        end
      end
    end

    def *(by)
      multiply_or_divide(:*, by)
    end

    def /(by)
      multiply_or_divide(:/, by)
    end

    # Compare equality between objects
    #
    # Returns true or false
    def matches?(other)
      operable_values == other.operable_values
    end

  end
end
