require 'spec_helper'

RSpec.describe RuboCop::Cop::RailsDdd::PrefixTopLevelConstants, :config do
  let(:message) { "Prefix top level constants with ::" }
  subject(:cop) { described_class.new(config) }

  context 'referring to a top level constant for another namespace' do
    let(:expected) do
      <<-OUTPUT
        module OtherNamespace
        end

        module Namespace
          klass = OtherNamespace
                  ^^^^^^^^^^^^^^ #{message}
        end
      OUTPUT
    end

    it do
      expect_offense(expected, 'app/concepts/namespace.rb')
    end
  end

  context 'with a normal top level constant' do
    let(:expected) do
      <<-OUTPUT
        module Namespace
        end
      OUTPUT
    end

    it do
      expect_no_offenses(expected, 'app/concepts/namespace.rb')
    end
  end
end
