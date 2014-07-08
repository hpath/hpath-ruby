class Hpath::Filter
  attr_accessor :operands
  attr_accessor :type

  def initialize(string = nil)
    string = string.dup unless string.nil? # we should not use the referenced string

    @type, @operands =
    if string.nil?
      [:and, []]
    else
      case string
      when /=/  then [:equality, string.split("=")]
      when /</  then [:less_than, string.split("<")]
      when />/  then [:greater_than, string.split(">")]
      when /\?/ then [:existence, string.split("?")]
      else [:index, [string[/^\d+$/] ? string.to_i : string]] # convert strings to integer of possible
      end
    end

    @operands.select! { |operand| operand != "" } if @operands.is_a?(Array)
  end

  def applies?(object)
    if @type == :and
      @operands.all? { |filter| filter.applies?(object) }
    elsif @type == :or
      @operands.any? { |filter| filter.applies?(object) }
    elsif @type == :existence
      key = operands.first
      
      if object.is_a?(Hash)
        object.keys.include?(key.to_s) || object.keys.include?(key.to_sym)
      end
    elsif @type == :equality
      key, value = @operands
      
      if object.is_a?(Hash)
        object[key.to_s] == value.to_s || object[key.to_sym] == value.to_s ||
        object[key.to_s] == value.to_sym || object[key.to_sym] == value.to_sym
      elsif object.respond_to(key)
        object.send(key) == value
      end
    end
  end
end
