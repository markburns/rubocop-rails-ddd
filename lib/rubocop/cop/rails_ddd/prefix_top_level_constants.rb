module RuboCop
  module Cop
    module RailsDdd
      class PrefixTopLevelConstants < Cop
        MESSAGE = "Prefix top level constants with ::".freeze

        def on_const(node)
          return if top_level_constant_definition? node
          return if missing_prefix? node
          add_offense(node, location: :expression, message: MESSAGE)
        end

        def nested_constants?(node)
          node.type == :const && node&.children&.first&.type == :const
        end

        def top_level_constant_definition?(node)
          current_constant = RuboCop::RailsDdd::NestedConstantName.for node: node

          "::" + node&.to_a&.last&.to_s == current_constant
        end

        def missing_prefix?(node)
          !node.to_a.first.nil?
        end
      end
    end
  end
end
