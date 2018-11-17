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
          process(node)
        end

        def on_class(node)
          process(node)
        end

        def on_casgn(node)
          process(node)
        end

        def valid_constant_elsewhere?(node)
          constants = Helpers.find_constants_in(node: node.ancestors.last)
          constants.any? { |c| valid_fully_qualified_constant?(c, path) }
        end

        private

        def process(node)
          return unless concepts_folder?

          constant_name = Helpers.nested_constant_name_for(node: node)

          return if exact_constant? constant_name, path
          return if valid_constant_elsewhere?(node)
          location = node.casgn_type? ? :name : :expression
          return if acceptable_higher_level_constant?(constant_name, path)

          add_offense(node, location: location, message: message)
        end

        def acceptable_higher_level_constant?(constant_name, path)
          valid_namespace?(constant_name, path) &&
            less_nested_constant_than_path_expects?(constant_name, path)
        end

        def exact_constant?(constant_name, path)
          constant_name == Helpers.constant_name_from(path)
        end

        def less_nested_constant_than_path_expects?(constant_name, path)
          nesting_level(constant_name) < nesting_level(Helpers.constant_name_from(path))
        end

        def nesting_level(constant_name)
          constant_name.split("::").length
        end

        def message
          "Incorrect constant name for #{path}".freeze
        end

        def concepts_folder?
          path.match %r{app/concepts/}
        end

        def path
          processed_source.path
        end

        delegate :valid_namespace?, :valid_fully_qualified_constant?, to: Helpers
      end
    end
  end
end
