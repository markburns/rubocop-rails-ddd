require 'spec_helper'
require 'parser/current'

RSpec.describe RuboCop::Cop::RailsDdd::ReachingInsideNamespaces, :config do
  subject(:cop) { described_class.new(config) }

  context 'with an incorrect filename' do
    let(:expected) do
      <<-OUTPUT
        module Namespace
          def self.a_method
            ::AnotherNamespace::AnotherClass.some_method
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't reach inside other namespaces. Refactor to avoid this or provide a public aggregate root method.
          end
        end
      OUTPUT
    end

    it do
      expect_offense(expected, 'app/concepts/namespace.rb')
    end
  end
end
