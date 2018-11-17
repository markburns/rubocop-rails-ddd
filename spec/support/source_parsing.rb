require 'parser/current'

module SourceParsing
  def node
    # example from http://www.rubydoc.info/gems/rubocop/RuboCop/AST/Builder
    buffer = Parser::Source::Buffer.new('')
    buffer.source = source

    builder = RuboCop::AST::Builder.new
    parser = Parser::CurrentRuby.new(builder)
    parser.parse(buffer)
  end
end

RSpec.configure do |c|
  c.include SourceParsing
end
