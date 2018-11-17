# frozen_string_literal: true
module RuboCop
  module Cop
    module RailsDdd
      module Helpers
        module NestedConstantName
          def self.for(node:, const_chain: [])
            return '::' + const_chain.compact.reverse.join('::') if node.nil?

            const_name =
              if node.class_type? || node.module_type?
                node.children.first.const_name
              end

            const_chain << const_name

            self.for(node: node.parent, const_chain: const_chain)
          end
        end
      end
    end
  end
end
