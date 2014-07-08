class Hpath::Parser
  require_relative "./parser/filter_expression_parser"

  def self.parse(string)
    self.new.parse(string)
  end

  def parse(string)
    string
    .split("/")
    .delete_if { |path_element| path_element.empty? }
    .map! do |path_element|
      identifier, filter_expression = path_element.gsub("]", "").split("[")
      filter = FilterExpressionParser.parse(filter_expression) if filter_expression

      {
        identifier: identifier == "" ? nil : identifier,
        filter: filter
      }
      .select { |key, value| !value.nil? }
    end
  end
end
