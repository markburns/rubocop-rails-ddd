
# frozen_string_literal: true

module RuboCop
  module Cop
    module RailsDdd
      module Helpers
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
      end
    end
  end
end
