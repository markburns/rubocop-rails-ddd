require 'spec_helper'

RSpec.describe RuboCop::Cop::RailsDdd::NamespacingMissing, :config do
  subject(:cop) { described_class.new(config) }

  let(:expected) do
    [ruby, error].compact.map(&:chomp).join("\n") + "\n"
  end

  context "with no namespace" do
    let(:expected) do
      <<-OUTPUT
        class SomeFile
        ^^^^^^^^^^^^^^ Classes in app/concepts should have a namespace
        end
      OUTPUT
    end

    it 'registers an offense for a class without a namespace' do
      expect_offense(expected, 'app/concepts/some_file.rb')
    end
  end

  context "with a namespace" do
    let(:expected) do
      <<-OUTPUT
        module SomeFile
          module Another
            class SomeClass
            end
          end
        end
      OUTPUT
    end

    it 'registers no offenses for a class without a namespace' do
      expect_no_offenses(expected, 'app/concepts/some_file.rb')
    end
  end
end
