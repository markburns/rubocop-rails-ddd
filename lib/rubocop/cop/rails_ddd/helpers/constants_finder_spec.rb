# frozen_string_literal: true
module RuboCop
  module Cop
    module RailsDdd
      module Helpers
        ::RSpec.describe ConstantsFinder do
          let(:constants) { described_class.for(node: node) }

          context "with an assigned constant" do
            let(:source) do
              <<-RUBY
                module SomeFile
                  This = 1
                end
              RUBY
            end

            it do
              expect(constants).to match_array %w(::SomeFile ::SomeFile::This)
            end
          end

          context "with a Struct" do
            let(:source) do
              <<-RUBY
                This = Struct.new
              RUBY
            end

            it do
              expect(constants).to match_array %w(::This)
            end
          end
          let(:source) do
            <<-RUBY
              module SomeFile
                module AnotherConstant
                  class IncorrectName
                  end

                  class AnotherWrongName
                  end
                end
              end
            RUBY
          end


          it do
            expect(constants).to match_array [
              '::SomeFile',
              '::SomeFile::AnotherConstant',
              '::SomeFile::AnotherConstant::IncorrectName',
              '::SomeFile::AnotherConstant::AnotherWrongName'
            ]
          end

          context 'with complex example' do
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

                  Tomato    = Struct.new(:num_seeds)
                  VERY_LOUD = 11
                  This      = Class.new(StandardError)

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
                '::Egg',
                '::Dog',
                '::Another',
                '::Another::Nested',
                '::Something',
                '::Something::Tomato',
                '::Something::VERY_LOUD',
                '::Something::This',
                '::Something::InsideMetaClass',
                '::Something::This',
                '::Something::This::That'
              ]
            end
          end
        end
      end
    end
  end
end
