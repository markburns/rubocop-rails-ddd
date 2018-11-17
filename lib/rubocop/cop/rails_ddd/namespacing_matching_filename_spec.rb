require 'spec_helper'

RSpec.describe RuboCop::Cop::RailsDdd::NamespacingMatchingFilename, :config do
  subject(:cop) { described_class.new(config) }

  let(:expected) do
    [ruby, error].compact.map(&:chomp).join("\n") + "\n"
  end

  context 'with an incorrect filename' do
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

  context 'with a correct filename' do
    let(:expected) do
      <<-OUTPUT
        module SomeFile; end
      OUTPUT
    end

    it do
      expect_no_offenses(expected, 'app/concepts/some_file.rb')
    end
  end

  context 'nested' do
    let(:expected) do
      <<-OUTPUT
        module SomeFile; class AnotherConstant; end; end
      OUTPUT
    end

    it do
      expect_no_offenses(expected, 'app/concepts/some_file/another_constant.rb')
    end
  end

  context 'invalid nested module' do
    let(:expected) do
      <<-OUTPUT
        module SomeFile
          module Wrong
          ^^^^^^^^^^^^ Incorrect constant name for app/concepts/some_file/another_constant.rb
          end
        end
      OUTPUT
    end

    it do
      expect_offense(expected, 'app/concepts/some_file/another_constant.rb')
    end
  end

  context 'non-matching nested module with matching module elsewhere' do
    let(:expected) do
      <<-OUTPUT
        module SomeFile
          class AnotherConstant
          end

          module Wrong
          end
        end
      OUTPUT
    end

    it do
      expect_no_offenses(expected, 'app/concepts/some_file/another_constant.rb')
    end
  end

  context 'nested again' do
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

  context 'with an invalid class name in the file' do
    let(:source) { expected.gsub(/^\s*\^.*$/, '') }

    let(:path) { 'app/concepts/some_file/another_constant/yet_another_constant.rb' }

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

    describe '#valid_constant_elsewhere?' do
      before do
        allow(cop).to receive(:path).and_return path
      end

      it do
        expect(cop.valid_constant_elsewhere?(node)).to eq false
      end
    end
  end

  context 'with other constants in the file' do
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
      filename = 'app/concepts/' \
                 'some_file/another_constant/yet_another_constant.rb'

      expect_no_offenses(expected, filename)
    end
  end

  context 'with various constant values in the file and no correct constant' do
    let(:expected) do
      <<-OUTPUT
        module SomeFile
          module AnotherConstant
            VERY_LOUD = 11
            ^^^^^^^^^ Incorrect constant name for app/concepts/some_file/another_constant/yet_another_constant.rb
            This      = Class.new(StandardError)
            ^^^^ Incorrect constant name for app/concepts/some_file/another_constant/yet_another_constant.rb
            Tomato    = Struct.new(:num_seeds)
            ^^^^^^ Incorrect constant name for app/concepts/some_file/another_constant/yet_another_constant.rb
            Spinach   = Struct.new(:num_leaves)
            ^^^^^^^ Incorrect constant name for app/concepts/some_file/another_constant/yet_another_constant.rb
          end
        end
      OUTPUT
    end

    it do
      filename = 'app/concepts/' \
                 'some_file/another_constant/yet_another_constant.rb'

      expect_offense(expected, filename)
    end
  end

  context 'with various constant values in the file and the correct constant' do
    let(:expected) do
      <<-OUTPUT
        module SomeFile
          module AnotherConstant
            class YetAnotherConstant
            end

            VERY_LOUD = 11
            This      = Class.new(StandardError)
            Tomato    = Struct.new(:num_seeds)
            Spinach   = Struct.new(:num_leaves)
          end
        end
      OUTPUT
    end

    it do
      filename = 'app/concepts/' \
                 'some_file/another_constant/yet_another_constant.rb'

      expect_no_offenses(expected, filename)
    end
  end
end
