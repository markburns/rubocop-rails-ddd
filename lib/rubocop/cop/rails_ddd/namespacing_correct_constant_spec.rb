require 'spec_helper'

RSpec.describe RuboCop::Cop::RailsDdd::NamespacingCorrectConstant, :config do
  subject(:cop) { described_class.new(config) }

  let(:expected) do
    [ruby, error].compact.map(&:chomp).join("\n") + "\n"
  end

  context "with just a top level namespace" do
    let(:expected) do
      <<-OUTPUT
        module SomeFile; end
        ^^^^^^^^^^^^^^^^^^^^ Modules in app/concepts should be correctly named
      OUTPUT
    end

    context "with an incorrect filename" do
      it do
        expect_offense(expected, 'app/concepts/something_else.rb')
      end
    end

    context "with a correct filename" do
      let(:expected) do
        <<-OUTPUT
          module SomeFile; end
        OUTPUT
      end

      it do
        expect_no_offenses(expected, 'app/concepts/some_file.rb')
      end
    end
  end
end
