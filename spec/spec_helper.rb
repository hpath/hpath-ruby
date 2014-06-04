require "hpath"
begin
  require "pry"
rescue LoadError
end

RSpec.configure do |config|
end

def read_asset(path_to_file)
  File.read(File.expand_path(File.join(File.dirname(__FILE__), "assets", path_to_file)))
end
