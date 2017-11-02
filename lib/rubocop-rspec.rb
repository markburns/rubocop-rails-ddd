require 'pathname'
require 'yaml'

require 'rubocop'

require 'rubocop/rspec'
require 'rubocop/rspec/version'
require 'rubocop/rspec/inject'
require 'rubocop/rspec/top_level_describe'
require 'rubocop/rspec/wording'
require 'rubocop/rspec/language'
require 'rubocop/rspec/language/node_pattern'
require 'rubocop/rspec/concept'
require 'rubocop/rspec/example_group'

RuboCop::RSpec::Inject.defaults!

# cops
require 'rubocop/cop/rspec/file_path'
# We have to register our autocorrect incompatibilies in RuboCop's cops as well
# so we do not hit infinite loops

module RuboCop
  module Cop
    module Layout
      class ExtraSpacing # rubocop:disable Style/Documentation
        def self.autocorrect_incompatible_with
          [RSpec::AlignLeftLetBrace, RSpec::AlignRightLetBrace]
        end
      end
    end
  end
end
