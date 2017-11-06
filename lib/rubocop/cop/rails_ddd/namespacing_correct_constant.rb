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
      class NamespacingCorrectConstant < Cop
        include RuboCop::RailsDdd::TopLevelDescribe

        MSG = 'Modules in app/concepts should be correctly named'.freeze

        def_node_search :const_described?,  '(send _ :describe (const ...) ...)'
        def_node_search :routing_metadata?, '(pair (sym :type) (sym :routing))'

        def on_module(node)
          return unless concepts_folder?
          return if !!node.parent
          const = node.defined_module_name

          return if expected_constant_name == const

          add_offense(node, location: :expression, message: MSG )
        end

        private

        def expected_constant_name
          path_name.gsub(/\.rb\z/, "").camelize
        end

        def path_name
          path.gsub(%r{\Aapp/concepts/}, "")
        end

        def concepts_folder?
          path.match %r{app/concepts/}
        end

        def path
          processed_source.path
        end

        def camelize(string)
          string
            .gsub(/([^a-z])_([a-z]+)/, '\1_\2')
            .gsub(/([a-z])_([a-z][^a-z\d]+)/, '\1_\2')
            .split("_")
            .map(&:capitalize)
            .join("")
        end

        def camel_to_snake_case(string)
          string
            .gsub(/([^A-Z])([A-Z]+)/, '\1_\2')
            .gsub(/([A-Z])([A-Z][^A-Z\d]+)/, '\1_\2')
            .downcase
        end

        def filename_ends_with?(glob)
          File.fnmatch?("*#{glob}", processed_source.buffer.name)
        end
      end
    end
  end
end
