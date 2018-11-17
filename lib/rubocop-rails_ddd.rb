require 'pathname'
require 'active_support/core_ext/string'
require 'yaml'

require 'rubocop'

require 'rubocop/rails_ddd/version'

require 'rubocop/cop/rails_ddd/constant_path_determination.rb'
require 'rubocop/cop/rails_ddd/constants_finder.rb'
require 'rubocop/cop/rails_ddd/nested_constant_name.rb'

# cops
require 'rubocop/cop/rails_ddd/namespacing_matching_filename.rb'
require 'rubocop/cop/rails_ddd/reaching_inside_namespaces.rb'
require 'rubocop/cop/rails_ddd/prefix_top_level_constants.rb'
# We have to register our autocorrect incompatibilies in RuboCop's cops as well
# so we do not hit infinite loops

module RuboCop
  module Cop
    module Layout
      class ExtraSpacing # rubocop:disable Style/Documentation
        def self.autocorrect_incompatible_with; end
      end
    end
  end
end
