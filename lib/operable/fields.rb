module Operable
  module Fields

    extend ActiveSupport::Concern

    # Return a list of attributes (with values) to be included in operations
    #
    # Returns Hash of key (string) => value pairs
    def operable_values
      raise "Please specify one or more fields via operable_on in your model definition!" if self.class.operable_fields.nil?

      values = {}
      attributes.select {|k, v| self.class.operable_fields.include? k }.each do |k, v|
        values[k.to_s] = v
      end

      if respond_to?(:reflections)
        reflections.select {|k, v| self.class.operable_fields.include? k.to_s }.each do |k, v|
          if self.send(k).present?
            values[k.to_s] = send(k)
          end
        end
      end

      if respond_to?(:associations)
        associations.select {|k, v| self.class.operable_fields.include? k.to_s }.each do |k, v|
          values[k.to_s] = send(k)
        end
      end

      values
    end

  end
end
