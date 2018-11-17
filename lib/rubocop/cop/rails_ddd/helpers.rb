require 'rubocop/cop/rails_ddd/helpers/constant_path_determination.rb'
require 'rubocop/cop/rails_ddd/helpers/constants_finder.rb'
require 'rubocop/cop/rails_ddd/helpers/nested_constant_name.rb'

module RuboCop
  module Cop
    module RailsDdd
      module Helpers
        def self.nested_constant_name_for(node:)
          NestedConstantName.for(node: node)
        end

        def self.find_constants_in(node: node)
          ConstantsFinder.for(node: node)
        end

        def self.valid_fully_qualified_constant?(const_name, path)
          ConstantPathDetermination.valid_fully_qualified_constant?(const_name, path)
        end

        def self.valid_namespace?(const_name, path)
          ConstantPathDetermination.valid_namespace?(const_name, path)
        end

        def self.constant_name_from(path)
          Helpers::ConstantPathDetermination.expected_const_name(path)
        end
      end
    end
  end
end
