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

  context "with an invalid class name in the file" do
    let(:expected) do
      <<-OUTPUT
        module SomeFile
          module AnotherConstant
            class IncorrectName
            ^^^^^^^^^^^^^^^^^^^ Incorrect constant name for app/concepts/some_file/another_constant/yet_another_constant.rb
            end

            class AnotherWrongName
            ^^^^^^^^^^^^^^^^^^^^^^ Incorrect constant name for app/concepts/some_file/another_constant/yet_another_constant.rb
            end
          end
        end
      OUTPUT
    end

    it do
      expect_offense(expected, path)
    end

    let(:source) { expected.gsub(/^\s*\^.*$/, "") }

      require 'parser/current'

    let(:node) do
      # example from http://www.rubydoc.info/gems/rubocop/RuboCop/AST/Builder
      buffer = Parser::Source::Buffer.new('')
      buffer.source = source

      builder = RuboCop::AST::Builder.new
      parser = Parser::CurrentRuby.new(builder)
      parser.parse(buffer)
    end

    let(:path) { 'app/concepts/some_file/another_constant/yet_another_constant.rb' }

    describe "#valid_constant_exists_in_file?" do
      before do
        allow(cop).to receive(:path).and_return path
      end

      it do
        expect(cop.valid_fully_qualified_constant_exists_in_file?(node)).to eq false
      end
    end

    describe described_class::ValidConstantPathDetermination do
      let(:valid) { described_class.valid?(const_name, path) }

      context "with a top level constant" do
        let(:const_name) { "::TopLevel" }
        let(:path) { "app/concepts/top_level.rb" }
        it do
          expect(valid).to be true
        end
      end

      context "with a nested constant" do
        let(:const_name) { "::TopLevel::Nested" }
        let(:path) { "app/concepts/top_level/nested.rb" }
        it do
          expect(valid).to be true
        end
      end

      context "a top level constant in a nested path" do
        let(:const_name) { "::TopLevel" }
        let(:path) { "app/concepts/top_level/nested.rb" }
        it do
          expect(valid).to be true
        end
      end

      context "with nonsense constant name" do
        let(:const_name) { "123" }
        let(:path) { "app.rb" }
        it do
          expect(valid).to be false
        end
      end

      context "with nonsense constant name matching the path" do
        let(:const_name) { "123" }
        let(:path) { "123.rb" }
        it do
          expect(valid).to be false
        end
      end

      context "an incorrect top level constant in a nested path" do
        let(:const_name) { "::Wrong::Nested" }
        let(:path) { "app/concepts/top_level/nested.rb" }
        it do
          expect(valid).to be false
        end
      end

      context "an incorrect nested constant" do
        let(:const_name) { "::TopLevel::Wrong" }
        let(:path) { "app/concepts/top_level/nested.rb" }
        it do
          expect(valid).to be false
        end
      end
    end

    describe described_class::SingleConstantFinder do

      context "with child class node" do
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
          expect(constant).to eq "::Outer::Inner::SomeClass"
        end
      end
    end

    describe described_class::ConstantFinder do
      let(:constants) { described_class.for(node: node) }

      it do
        expect(constants).to match_array [
          "::SomeFile",
          "::SomeFile::AnotherConstant",
          "::SomeFile::AnotherConstant::IncorrectName",
          "::SomeFile::AnotherConstant::AnotherWrongName",
        ]
      end

      context "with complex example" do
        let(:source) do
          <<-RUBY
          class Egg
          end
            class Dog
            end
            class Another
              class Nested
              end
            end
            class Something
              include Thing
              def self.asdf(a, b=2, asdf: qwer)
              end
              class << self
                module InsideMetaClass
                end
              end
              module This
                attr_reader :anything
                class That
                end
              end
            end
              RUBY
        end
        it do
          expect(constants).to match_array [
            "::Egg",
            "::Dog",
            "::Another",
            "::Another::Nested",
            "::Something",
            "::Something::InsideMetaClass",
            "::Something::This",
            "::Something::This::That"
          ]
        end
        end
      end
    end

    context "with other constants in the file" do
      let(:expected) do
        <<-OUTPUT
        module SomeFile
          module AnotherConstant
            class YetAnotherConstant
            end

            class AcceptableYetUnpredictableClassName
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
        expect(described_class.for("SomeFile")).to eq ["::SomeFile"]
        expected_results = [
          "::SomeFile",
          "::SomeFile::SomeNamespace",
          "::SomeFile::SomeNamespace::AnotherNamespace",
          "::SomeFile::SomeNamespace::AnotherNamespace::FinalConstant"
        ]

        expect(described_class.for("SomeFile::SomeNamespace::AnotherNamespace::FinalConstant")).to eq expected_results
      end
    end
  end
