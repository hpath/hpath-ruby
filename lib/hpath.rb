module Hpath
  require "hpath/filter"
  require "hpath/parser"
  require "hpath/version"

  def self.get(object, hpath_string)
    hpath = Hpath::Parser.parse(hpath_string)
    _get(object, hpath[:path])
  end

  def self.set(object, hpath_string, value)
    hpath = Hpath::Parser.parse(hpath_string)
    _set(object, hpath[:path], value)
  end

  #
  private
  #
  def self._get(object, paths, parent = object)
    _object = object

    if paths.empty?
      return object
    else
      path = paths.shift
    end

    if path[:identifier]
      object = _resolve_identifier(object, path[:identifier])
    elsif path[:axis] == "parent"
      object = parent
    end

    if path[:indices]
      object = _resolve_indices(object, path[:indices])
    elsif path[:keys]
      object = _resolve_keys(object, path[:keys])
    end

    unless path[:filter].nil?
      object = _apply_filters(object, Hpath::Filter.new(path[:filter]))
    end

    self._get(object, paths, _object)
  end

  def self._set(object, paths, value)
    if paths.empty?
      if object.is_a?(Array)
        object.push(value)
      elsif object.is_a?(Hash)
        object.merge!(value)
      end

      return
    else
      path = paths.shift
    end

    if (_object = self._get(object, [path])).nil?
      if object.is_a?(Array)
        if path[:type] == Array
          object.push(_object = [])
        elsif path[:type] == Hash
          object.push({ path[:identifier].to_sym => (_object = {}) })
        end
      elsif object.is_a?(Hash)
        object[path[:identifier].to_sym] = (_object = path[:type].new)
      end
    end

    self._set(_object, paths, value)
  end

  def self._apply_filters(object, filter)
    if object.is_a?(Array)
      object.select do |element|
        filter.applies?(element)
      end
    else
      # TODO
    end
  end

  def self._resolve_identifier(object, identifier)
    if object.is_a?(Array) && !object.empty?
      if identifier.to_s == "*"
        object
      else
        object.map do |element|
          if element.is_a?(Hash)
            element[identifier.to_s] || element[identifier.to_sym] 
          elsif element.respond_to?(identifier)
            element.send(identifier)
          else
            raise "Cannot apply identifier to collection object!"
          end
        end
      end
    elsif object.is_a?(Hash)
      if identifier.to_s == "*"
        object.map { |key, value| {key => value} }
      else
        object[identifier.to_s] || object[identifier.to_sym]
      end
    else
      # TODO
    end
  end

  def self._resolve_indices(object, indices)
    if indices.length == 1
      object[indices.first]
    elsif indices.length > 1
      indices.map { |index| object[index] }
    end
  end

  def self._resolve_keys(object, keys)
    if object.is_a?(Hash)
      object.select { |key, value| keys.include?(key.to_s) || keys.include?(key.to_sym) }
    else
      raise "Cannot resolve keys for non-hash objects!"
    end
  end
end
