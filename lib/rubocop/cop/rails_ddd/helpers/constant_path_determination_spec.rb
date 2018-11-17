require "spec_helper"
module RuboCop
  module Cop
    module RailsDdd
      module Helpers
        ::RSpec.describe ConstantPathDetermination do
          let(:valid) { described_class.valid_namespace?(const_name, path) }

          context 'with a top level constant' do
            let(:const_name) { '::TopLevel' }
            let(:path) { 'app/concepts/top_level.rb' }

            it do
              expect(valid).to be true
            end
          end

          context 'with a nested constant' do
            let(:const_name) { '::TopLevel::Nested' }
            let(:path) { 'app/concepts/top_level/nested.rb' }
            it do
              expect(valid).to be true
            end
          end

          context 'a top level constant in a nested path' do
            let(:const_name) { '::TopLevel' }
            let(:path) { 'app/concepts/top_level/nested.rb' }
            it do
              expect(valid).to be true
            end
          end

          context 'with nonsense constant name' do
            let(:const_name) { '123' }
            let(:path) { 'app.rb' }
            it do
              expect(valid).to be false
            end
          end

          context 'with nonsense constant name matching the path' do
            let(:const_name) { '123' }
            let(:path) { '123.rb' }
            it do
              expect(valid).to be false
            end
          end

          context 'an incorrect top level constant in a nested path' do
            let(:const_name) { '::Wrong::Nested' }
            let(:path) { 'app/concepts/top_level/nested.rb' }
            it do
              expect(valid).to be false
            end
          end

          context 'an incorrect nested constant' do
            let(:const_name) { '::TopLevel::Wrong' }
            let(:path) { 'app/concepts/top_level/nested.rb' }
            it do
              expect(valid).to be false
            end
          end
        end
      end
    end
  end
end
