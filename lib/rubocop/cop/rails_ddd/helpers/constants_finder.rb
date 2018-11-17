
# frozen_string_literal: true
module RuboCop
  module Cop
    module RailsDdd
      module Helpers
        module ConstantsFinder
          def self.for(node:, constants: [], namespace: '')
            return constants unless node.is_a? RuboCop::AST::Node
            return constants if node.type == :const

            if node.module_type? || node.class_type?
              qualified_const_name = for_node(node: node, namespace: namespace)
              constants << qualified_const_name
            else
              qualified_const_name = namespace
            end

            node.children.each do |n|
              constants = self.for(node: n, constants: constants, namespace: qualified_const_name)
            end

            constants.compact
          end

          def self.for_node(node:, namespace: nil)
            return nil unless node.is_a? RuboCop::AST::Node
            return nil if node.type == :const

            if node.module_type? || node.class_type?
              [namespace, node.children.first.const_name].compact.join('::')
            end
          end
        end
      end
    end
  end
end
