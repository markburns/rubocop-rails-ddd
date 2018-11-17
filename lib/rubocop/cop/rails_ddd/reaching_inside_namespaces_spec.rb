require 'spec_helper'
require 'parser/current'

RSpec.describe RuboCop::Cop::RailsDdd::ReachingInsideNamespaces, :config do
  subject(:cop) { described_class.new(config) }

  context 'referring to a nested constant in another namespace' do
    let(:expected) do
      <<-OUTPUT
        module Namespace
          klass = ::AnotherNamespace::AnotherClass
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't reach inside other namespaces. Refactor to avoid this or provide a public aggregate root method.
        end
      OUTPUT
    end

    it do
      expect_offense(expected, 'app/concepts/namespace.rb')
    end
  end

  context 'calling a method on a nested constant' do
    let(:expected) do
      <<-OUTPUT
        module Namespace
          def self.a_method
            ::AnotherNamespace::AnotherClass.some_method
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't reach inside other namespaces. Refactor to avoid this or provide a public aggregate root method.
          end
        end
      OUTPUT
    end

    it do
      expect_offense(expected, 'app/concepts/namespace.rb')
    end
  end
end
