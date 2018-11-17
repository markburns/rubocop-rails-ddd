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
      #   # app/concepts/some_folder/nesting.rb
      #   module IncorrectlyNamed; end
      #
      #   # bad
      #   # app/concepts/some_folder/nesting.rb
      #   module SomeFolder; class IncorrectlyNamed; end; end
      #
      #   # good
      #   # app/concepts/some_folder.rb
      #   module SomeFolder; end
      #
      #   # good
      #   # app/concepts/some_folder/file.rb
      #   module SomeFolder; class File; end; end
      #
      class NamespacingMatchingFilename < Cop
        def on_module(node)
          return unless concepts_folder?

          constant_name = NestedConstantName.for(node: node)
          return if valid_namespace?(constant_name, path)
          return if valid_constant_elsewhere?(node)

          add_offense(node, location: :expression, message: message)
        end

        def on_class(node)
          return unless concepts_folder?

          return if valid_constant_elsewhere?(node)

          add_offense(node, location: :expression, message: message)
        end

        def valid_constant_elsewhere?(node)
          constants = ConstantsFinder.for(node: node.ancestors.last)
          constants.any? { |c| valid_fully_qualified_constant?(c, path) }
        end

        private

        def message
          "Incorrect constant name for #{path}".freeze
        end

        def concepts_folder?
          path.match %r{app/concepts/}
        end

        def path
          processed_source.path
        end

        delegate :valid_namespace?, :valid_fully_qualified_constant?, to: ConstantPathDetermination
      end
    end
  end
end
