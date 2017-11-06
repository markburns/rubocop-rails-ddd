require 'spec_helper'

RSpec.describe RuboCop::Cop::RailsDdd::NamespacingMatchingFilename, :config do
  subject(:cop) { described_class.new(config) }

  let(:expected) do
    [ruby, error].compact.map(&:chomp).join("\n") + "\n"
  end

  context "with an incorrect filename" do
    let(:expected) do
      <<-OUTPUT
        module SomeFile; end
        ^^^^^^^^^^^^^^^^^^^^ Incorrect constant name for app/concepts/something_else.rb
      OUTPUT
    end

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

  context "nested" do
    let(:expected) do
      <<-OUTPUT
        module SomeFile; class AnotherConstant; end; end
      OUTPUT
    end

    it do
      expect_no_offenses(expected, 'app/concepts/some_file/another_constant.rb')
    end
  end

  context "nested again" do
    let(:expected) do
      <<-OUTPUT
        module SomeFile
          module AnotherConstant
            class YetAnotherConstant
            end
          end
        end
      OUTPUT
    end

    it do
      expect_no_offenses(expected, 'app/concepts/some_file/another_constant/yet_another_constant.rb')
    end
  end

  describe described_class::ConstantNameFinder do
    it do
      expect(described_class.for("SomeFile")).to eq ["SomeFile"]
      expected_results = [
        "SomeFile",
        "SomeFile::SomeNamespace",
        "SomeFile::SomeNamespace::AnotherNamespace",
        "SomeFile::SomeNamespace::AnotherNamespace::FinalConstant"
      ]

      expect(described_class.for("SomeFile::SomeNamespace::AnotherNamespace::FinalConstant")).to eq expected_results
    end

  end
end
