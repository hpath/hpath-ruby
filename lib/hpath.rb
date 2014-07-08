module Hpath
  require "hpath/parser"
  require "hpath/version"

  def self.get(object, hpath_string)
    parsed_hpath = Hpath::Parser.parse(hpath_string)
    _get(object, parsed_hpath)
  end

  def self.set(object, hpath_string, value)
    parsed_hpath = Hpath::Parser.parse(hpath_string)
    _set(object, parsed_hpath, value)
  end

  #
  private
  #
  def self._dfs(object, filter)
    if filter.applies?(object)
      object
    elsif object.is_a?(Array)
      object.map { |e| _dfs(e, filter) }
      .tap { |o| o.compact! }
      .tap { |o| o.flatten!(1) }
    elsif object.is_a?(Hash)
      _dfs(object.values, filter)
    end
  end
  
  def self._get(object, paths, parent = object)
    _object = object

    if paths.empty?
      return object
    else
      path = paths.shift
    end

    if path[:identifier]
      if path[:identifier] == "**"
        object = _dfs(object, path[:filter])
      else
        object = _resolve_identifier(object, path[:identifier])
      end
    elsif path[:axis] == "parent"
      object = parent
    end

    if path[:filter] && !(path[:identifier] && path[:identifier] == "**")
      filter = path[:filter]

      object =
      if filter.type == :index
        indices = path[:filter].operands

        if object.is_a?(Array)
          if indices.length == 1
            object[indices.first]
          elsif indices.length > 1
            indices.map { |index| object[index] }
          end
        elsif object.is_a?(Hash)
          object.select do |key, value|
            indices.include?(key.to_s) || indices.include?(key.to_sym)
          end
        end
      else
        if object.is_a?(Array)
          object.select do |element|
            filter.applies?(element)
          end
        else
          # TODO
        end
      end
    end

    self._get(object, paths, _object)
  end

  def self._set(object, paths, value)
    if paths.empty?
      return
    else
      path = paths.shift
    end

    if (_object = self._get(object, [path])).nil?
      if object.is_a?(Array)
        unless paths.empty?
          object.push({ path[:identifier].to_sym => (_object = {}) })
        else
          object.push({ path[:identifier].to_sym => (_object = value) })
        end
      elsif object.is_a?(Hash)
        unless paths.empty?
          object[path[:identifier].to_sym] = (_object = {})
        else
          object[path[:identifier].to_sym] = (_object = value)
        end
      end
    end

    self._set(_object, paths, value)
  end

  def self._resolve_identifier(object, identifier)
    if object.is_a?(Array) && !object.empty?
      if identifier.to_s == "*"
        object
      else
        mapped_object = object.map do |element|
          if element.is_a?(Hash)
            element[identifier.to_s] || element[identifier.to_sym] 
          elsif element.respond_to?(identifier)
            element.send(identifier)
          else
            nil
          end
        end.compact.flatten(1)

        mapped_object unless mapped_object.empty?
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
end
