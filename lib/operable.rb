require 'active_support'
require 'operable/fields'
require 'operable/operations'
require 'operable/version'

module Operable

  extend ActiveSupport::Concern

  include Operable::Fields
  include Operable::Operations

  included do
    cattr_accessor :operable_fields
  end

  module ClassMethods

    INOPERABLE_FIELDS = %w[_type _id created_at updated_at version]

    def operable_on(*names)
      fields = operable_fields || []
      self.operable_fields = [fields, names].flatten.map(&:to_s).uniq.sort
    end

    def operable_on_all
      raise "Unable to list all fields for this ORM" unless respond_to?(:fields)
      self.operable_fields = fields.keys.reject {|k| INOPERABLE_FIELDS.include? k }
    end

    def operable_on_all_except(*names)
      self.operable_fields = operable_on_all.reject {|k| names.map(&:to_s).include? k }
    end

  end

end
