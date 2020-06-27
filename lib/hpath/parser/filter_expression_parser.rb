class Hpath::Parser::FilterExpressionParser
  require "hpath/filter"

  def self.parse(string)
    self.new.parse(string)
  end

  def flush_char_buffer(char_buffer, filter)
    unless char_buffer.empty?
      new_filter = Hpath::Filter.new(char_buffer)

      if
      new_filter.type == :index &&
      !filter.operands.empty? &&
      filter.operands.all? { |operand| operand.type == :index }
        filter.operands.first.operands << new_filter.operands.first
      else
        filter.operands << new_filter
      end

      char_buffer.clear
    end
  end

  def parse(string)
    # reset parser
    char_buffer = ""
    current_filter = Hpath::Filter.new
    parent = {} # look up table    
    
    string.each_char do |char|
      unless special_character?(char)
        char_buffer << char
      else
        flush_char_buffer(char_buffer, current_filter)
        
        if char == "("
          new_filter = Hpath::Filter.new
          parent[new_filter] = current_filter
          current_filter.operands << new_filter
          current_filter = new_filter
        elsif char == ")"
          # replace operation by operand in parent if only one operand
          if current_filter.operands.length == 1
            parent[current_filter].operands.map! do |operand|
              operand == current_filter ? current_filter.operands.first : operand
            end
          end

          current_filter = parent[current_filter]
        elsif char == "," || char == "|"
          operator =
          case char
          when "," then :and
          when "|" then :or
          end

          unless current_filter.operands.length == 2
            current_filter.type = operator
          else
            if current_filter.type == :or && operator == :and
              new_filter = Hpath::Filter.new.tap do |filter|
                filter.operands << current_filter.operands.pop
                filter.type = operator
              end

              parent[new_filter] = current_filter
              current_filter.operands << new_filter
            else
              new_filter = Hpath::Filter.new.tap do |filter|
                filter.operands << current_filter
                filter.type = operator
              end

              parent[new_filter] = parent[current_filter]
              parent[current_filter] = new_filter
            end

            current_filter = new_filter
          end
        end
      end
    end

    flush_char_buffer(char_buffer, current_filter)

    while parent[current_filter] != nil
      current_filter = parent[current_filter]
    end

    if current_filter.operands.length == 1
      current_filter.operands.first
    else
      current_filter
    end
  end

  #
  private
  #
  def special_character?(char)
    char[/[(),\|]/] == nil ? false : true
  end
end
