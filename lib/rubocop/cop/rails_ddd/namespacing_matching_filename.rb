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
      #   app/concepts/some_folder/nesting.rb # module IncorrectlyNamed; end
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
      class NamespacingMatchingFilename < Cop
        def on_module(node)
          return unless concepts_folder?

          constant_name = SingleConstantFinder.for(node: node)
          return if ValidConstantPathDetermination.valid?(constant_name, path)

          add_offense(node, location: :expression, message: message)
        end

        def on_class(node)
          return unless concepts_folder?

          return if valid_fully_qualified_constant_exists_in_file?(node)

          add_offense(node, location: :expression, message: message)
        end

        def valid_fully_qualified_constant_exists_in_file?(node)
          constants = ConstantFinder.for(node: node.ancestors.last)
          constants.any?{|c| ValidConstantPathDetermination.valid_fully_qualified_constant?(c, path) }
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

        module SingleConstantFinder
          def self.for(node: node, namespace: nil)
            return nil unless node.is_a? RuboCop::AST::Node
            return nil if node.type == :const

            infer_namespace(node)
          end

          def self.infer_namespace(node, const_chain: [])
            return "::" + const_chain.compact.reverse.join("::") if node.nil?

            const_name = if node.class_type? || node.module_type?
              node.children.first.const_name
            end

            const_chain << const_name

            infer_namespace(node.parent, const_chain: const_chain)
          end

        end

        module ConstantFinder
          def self.for(node: node, constants: [], namespace: "")
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

          def self.for_node(node: node, namespace: nil)
            return nil unless node.is_a? RuboCop::AST::Node
            return nil if node.type == :const

            if node.module_type? || node.class_type?
              [namespace, node.children.first.const_name].compact.join("::")
            end
          end
        end

        module ValidConstantPathDetermination
          def self.valid_fully_qualified_constant?(const_name, path)
            expected_const_name(path) == const_name
          end

          def self.valid?(const_name, path)
            expected_const_name(path).starts_with? const_name
          end

          def self.expected_const_name(path)
            "::" +
              path.
              gsub(%r{app/concepts/}, "").
              gsub(%r{\.rb\z}, "").
              camelize
          end
        end
      end
    end
  end
end
