module RuboCop
  module Cop
    module RailsDdd
      class ReachingInsideNamespaces < Cop
        def on_const(node)
          return unless nested_constants? node
          message = "Don't reach inside other namespaces. Refactor to avoid this or provide a public aggregate root method."
          add_offense(node, location: :expression, message: message)
        end

        def nested_constants?(node)
          node.type == :const && node&.children&.first&.type == :const
        end
      end
    end
  end
end
