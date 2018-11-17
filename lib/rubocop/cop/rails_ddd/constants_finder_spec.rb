# frozen_string_literal: true

module RuboCop
  module Cop
    module RailsDdd
      ::RSpec.describe ConstantsFinder do
        let(:constants) { described_class.for(node: node) }
        let(:source) do
          <<-OUTPUT
            module SomeFile
              module AnotherConstant
                class IncorrectName
                end

                class AnotherWrongName
                end
              end
            end
          OUTPUT
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
