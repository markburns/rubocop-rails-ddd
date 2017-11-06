$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'rubocop/rails_ddd/version'

Gem::Specification.new do |spec|
  spec.name = 'rubocop-rails_ddd'
  spec.summary = 'Code style checking for Rails DDD'
  spec.description = <<-DESCRIPTION
    Code style checking for Rails DDD.
    A plugin for the RuboCop code style enforcing & linting tool.
  DESCRIPTION
  spec.homepage = 'http://github.com/markburns/rubocop-rails_ddd'
  spec.authors = ['Mark Burns']
  spec.email = [
    'markthedeveloper@gmail.com',
  ]
  spec.licenses = ['MIT']

  spec.version = RuboCop::RailsDdd::Version::STRING
  spec.platform = Gem::Platform::RUBY
  spec.required_ruby_version = '>= 2.1.0'

  spec.require_paths = ['lib']
  spec.files = Dir[
    '{config,lib,spec}/**/*',
    '*.md',
    '*.gemspec',
    'Gemfile',
    'Rakefile'
  ]
  spec.test_files = spec.files.grep(%r{^spec/})
  spec.extra_rdoc_files = ['MIT-LICENSE.md', 'README.md']

  spec.add_runtime_dependency 'rubocop', '>= 0.51.0'
  spec.add_runtime_dependency 'rails', '>= 3'

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '>= 3.4'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'yard'
end
