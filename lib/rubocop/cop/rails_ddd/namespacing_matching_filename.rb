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

        module ConstantPathDetermination
          def self.valid_fully_qualified_constant?(const_name, path)
            expected_const_name(path) == const_name
          end

          def self.valid_namespace?(const_name, path)
            expected_const_name(path).starts_with?(const_name)
          end

          def self.expected_const_name(path)
            '::' +
              path
              .gsub(%r{.*/?app/concepts/}, '')
              .gsub(/\.rb\z/, '')
              .camelize
          end
        end

        delegate :valid_namespace?, :valid_fully_qualified_constant?, to: ConstantPathDetermination
      end
    end
  end
end
