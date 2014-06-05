module Hpath
  require "hpath/filter"
  require "hpath/parser"
  require "hpath/version"

  def self.get(object, hpath_string)
    hpath = Hpath::Parser.parse(hpath_string)
    _get(object, hpath[:path])
  end

  #
  private
  #
  def self._get(object, paths)
    if paths.empty?
      return object
    else
      path = paths.shift
    end

    if path[:identifier]
      object = _resolve_identifier(object, path[:identifier])
    end

    if path[:indices]
      object = _resolve_indices(object, path[:indices])
    elsif path[:keys]
      object = _resolve_keys(object, path[:keys])
    end

    unless path[:filter].nil?
      object = _apply_filters(object, Hpath::Filter.new(path[:filter]))
    end

    self._get(object, paths)
  end

  def self._apply_filters(object, filter)
    if object.is_a?(Array)
      object.select do |element|
        if element.is_a?(Hash)
          filter.applies?(element)
        else
          raise "Cannot filter non-hash array elements"
        end
      end
    else
      #binding.pry
    end
  end

  def self._resolve_identifier(object, identifier)
    if object.is_a?(Array)
      if identifier.to_s == "*"
        object
      else
        raise "Tried to access an array by a key!"
      end
    elsif object.is_a?(Hash)
      if identifier.to_s == "*"
        object.map { |key, value| {key => value} }
      else
        object[identifier]
      end
    else
      #binding.pry
    end
  end

  def self._resolve_indices(object, indices)
    if indices.length == 1
      object[indices.first]
    else
      indices.map { |index| object[index] }
    end
  end

  def self._resolve_keys(object, keys)
    if object.is_a?(Hash)
      object.select { |key, value| keys.include?(key) }
    else
      raise "Cannot resolve keys for non-hash objects!"
    end
  end
end
