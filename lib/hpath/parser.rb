require "parslet"

class Hpath::Parser
  def self.parse(string)
    self.new.parse(string)
  end

  def parse(string)
    transform(normalize(parser.parse(string)))
  end

  #
  private
  #
  def normalize(result_tree) # to ease transformation
    result_tree[:path].map! do |element|
      element[:axis] ||= nil
      element[:identifier] ||= nil
      element[:filter] ||= nil
      element[:indices] ||= nil
      element[:indices] = [element[:indices]] if !element[:indices].nil? && !element[:indices].is_a?(Array)
      element[:keys] ||= nil
      element[:keys] = [element[:keys]] if !element[:keys].nil? && !element[:keys].is_a?(Array)
      element
    end

    result_tree
  end

  def parser
    @parser ||=
    Class.new(Parslet::Parser) do
      rule(:space)  { match('\s').repeat(1) }
      rule(:space?) { space.maybe }

      rule(:key_value_filter) {
        space? >> match['a-zA-Z'].repeat(1).maybe.as(:key) >> (str("<") | str(">") | str("=").repeat(1,3)).as(:operator) >> match['a-zA-Z0-9'].repeat(1).as(:value) >> space?
      }

      rule(:or_filter) {
        ((and_filter.as(:and_filter) | key_value_filter.as(:key_value_filter)) >> str("|")).repeat(1) >> (and_filter.as(:and_filter) | key_value_filter.as(:key_value_filter))
      }

      rule(:primary) {
        str("(") >> or_filter.as(:or_filter) >> str(")")
      }

      rule(:and_filter) {
        ((primary | key_value_filter.as(:key_value_filter)) >>
        str(",")).repeat(1) >>
        (primary | key_value_filter.as(:key_value_filter))
      }

      rule(:filter) {
        space? >> (or_filter.as(:or_filter) | and_filter.as(:and_filter) | key_value_filter.as(:key_value_filter)).as(:filter) >> space?
      }

      rule(:keys) {
        match('[a-zA-Z0-9]').repeat(1).as(:key) >> (space? >> str(",") >> space? >> match('[a-zA-Z0-9]').repeat(1).as(:key)).repeat
      }

      rule(:indices) {
        match('[0-9]').repeat(1).as(:index) >> (space? >> str(",") >> match('[0-9]').repeat(1).as(:index)).repeat
      }

      rule(:identifier) {
        match('[a-zA-Z0-9*]').repeat(1)
      }

      rule(:node) {
        str("/") >> (identifier.as(:identifier) | (str("::") >> identifier.as(:axis))).maybe >> (str("[") >> space? >> (indices.as(:indices) | filter | keys.as(:keys)) >> space? >> str("]")).maybe
      }

      rule(:path) {
        node.repeat(1).as(:path)
      }

      # root
      root(:path)
    end.new
  end

  def transform(result_tree)
    transformation.apply(result_tree)
  end

  def transformation
    @transformation ||=
    Class.new(Parslet::Transform) do
      rule(axis: simple(:axis), identifier: simple(:identifier), filter: subtree(:filter), indices: subtree(:indices), keys: subtree(:keys)) {
        {
          axis: axis.nil? ? nil : axis.to_s,
          identifier: identifier.nil? ? nil : identifier.to_s,
          filter: filter,
          indices: indices.nil? ? nil : indices.map { |element| Integer(element[:index]) },
          keys: keys.nil? ? nil : keys.map { |element| element[:key].to_s.to_sym }
        }
      }

      rule(key: simple(:key), operator: simple(:operator), value: simple(:value)) {
        { key: key.nil? ? nil : key.to_sym, operator: operator.to_s, value: value.to_s }
      }
    end.new
  end
end
