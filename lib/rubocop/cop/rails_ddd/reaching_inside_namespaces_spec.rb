require 'spec_helper'
require 'parser/current'

RSpec.describe RuboCop::Cop::RailsDdd::ReachingInsideNamespaces, :config do
  let(:message) { "Don't reach inside other namespaces. Refactor to avoid this or provide a public aggregate root method." }
  subject(:cop) { described_class.new(config) }

  context 'referring to a constant inside the current namespace' do
    let(:expected) do
      <<-OUTPUT
        module Namespace
          class AnotherClass
          end
        end

        module Namespace
          klass = AnotherClass
        end
      OUTPUT
    end

    it do
      expect_no_offenses(expected, 'app/concepts/namespace.rb')
    end
  end


  context 'referring to a nested constant in another namespace' do
    let(:expected) do
      <<-OUTPUT
        module Namespace
          klass = ::AnotherNamespace::AnotherClass
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
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
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
          end
        end
      OUTPUT
    end

    it do
      expect_offense(expected, 'app/concepts/namespace.rb')
    end
  end
end
