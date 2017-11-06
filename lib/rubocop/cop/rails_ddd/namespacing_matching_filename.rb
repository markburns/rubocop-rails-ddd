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
        module ConstantNameFinder
          def self.for(class_name)
            # There is probably a prettier way to do this with some
            # Enumerable method, but I can't think of it right now
            levels = class_name.split("::")
            length = levels.length
            constants = []

            length.times.each do |i|
              constants.push levels[0..i].join("::")
            end

            constants
          end
        end

        def on_module(node)
          return unless concepts_folder?
          return if !!node.parent

          return if correct_module_name?(node)

          add_offense(node, location: :expression, message: message)
        end

        private

        def correct_module_name?(node)
          valid_constant_name?(node) && feasible_path?(node)
        end

        def valid_constant_name?(node)
          valid_constant_names.include? module_name(node)
        end

        def feasible_path?(node)
          expected_filename(node) == path || 
            path.match(%r{app/concepts/#{module_name(node).underscore}/.*\.rb})
        end

        def expected_filename(node)
          "app/concepts/" + module_name(node).underscore + ".rb"
        end

        def module_name(node)
          (node.ancestors + [node]).map(&:defined_module_name).join("::")
        end

        def message
          "Incorrect constant name for #{path}".freeze
        end

        def valid_constant_names
          ConstantNameFinder.for(full_expected_constant_name)
        end

        def full_expected_constant_name
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
      end
    end
  end
end
