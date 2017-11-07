require 'pathname'
require 'active_support/core_ext/string'
require 'yaml'

require 'rubocop'

require 'rubocop/rails_ddd'
require 'rubocop/rails_ddd/version'
require 'rubocop/rails_ddd/inject'
require 'rubocop/rails_ddd/top_level_describe'
require 'rubocop/rails_ddd/wording'
require 'rubocop/rails_ddd/language'
require 'rubocop/rails_ddd/language/node_pattern'
require 'rubocop/rails_ddd/concept'
require 'rubocop/rails_ddd/example_group'

RuboCop::RailsDdd::Inject.defaults!

# cops
require 'rubocop/cop/rails_ddd/namespacing_matching_filename.rb'
# We have to register our autocorrect incompatibilies in RuboCop's cops as well
# so we do not hit infinite loops

module RuboCop
  module Cop
    module Layout
      class ExtraSpacing # rubocop:disable Style/Documentation
        def self.autocorrect_incompatible_with
          [rails_ddd::AlignLeftLetBrace, rails_ddd::AlignRightLetBrace]
        end
      end
    end
  end
end
