# frozen_string_literal: true

module RuboCop
  module Cop
    module RailsDdd
      # Checks that classes are namespaced.
      #
      # Checks the path of the file and enforces that it reflects the
      # namespace and constant used.
      #
      # @example
      #   # bad
      #   app/concepts/some_file.rb           # class SomeFile; end
      #
      #   # bad
      #   app/concepts/some_folder/nesting.rb # module SomeFolder; class IncorrectlyNamed; end; end
      #
      #   # good
      #   app/concepts/some_folder.rb         # module SomeFolder; end
      #
      #   # good
      #   app/concepts/some_folder/file.rb    # module SomeFolder; class File; end; end
      #
      class NamespacingMissing < Cop
        include RuboCop::RailsDdd::TopLevelDescribe

        MSG = 'Classes in app/concepts should have a namespace'.freeze

        def_node_search :const_described?,  '(send _ :describe (const ...) ...)'
        def_node_search :routing_metadata?, '(pair (sym :type) (sym :routing))'

        def on_class(node)
          return unless concepts_folder?
          return if has_namespace?(node)

          add_offense(node, location: :expression, message: MSG )
        end

        private

        def concepts_folder?
          path.match %r{app/concepts/}
        end

        def path
          processed_source.path
        end

        def has_namespace?(node)
          !!node.parent
        end
      end
    end
  end
end
