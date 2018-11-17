module RuboCop
  module Cop
    module RailsDdd
      class ReachingInsideNamespaces < Cop
        def on_send(node)
          return unless nested_constants? node.children.first
          message = "Don't reach inside other namespaces. Refactor to avoid this or provide a public aggregate root method."
          lib/rubocop/cop/rails_ddd/reaching_inside_namespaces.rbadd_offense(node, location: :expression, message: message)
        end

        def nested_constants?(node)
          node.type == :const && node.children.first.type == :const
        end
      end
    end
  end
end
