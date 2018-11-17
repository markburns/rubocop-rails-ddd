# frozen_string_literal: true

module RuboCop
  module Cop
    module RailsDdd
      ::RSpec.describe NestedConstantName do
        context 'with child class node' do
          let(:nested_node) { node.children.last.children.last }
          let(:constant) { described_class.for(node: nested_node) }
          let(:source) do
            <<-RUBY
            module Outer
              module Inner
                class SomeClass
                end
              end
            end
            RUBY
          end

          it do
            expect(constant).to eq '::Outer::Inner::SomeClass'
          end
        end
      end
    end
  end
end
