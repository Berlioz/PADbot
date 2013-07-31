require 'data_mapper'
require 'json'
require 'yaml'
require 'pry'

Dir.glob("models/*.rb").each {|x| require_relative x}

config = YAML.load(File.read("database_config.yaml"))
DataMapper.setup(:default, config)
DataMapper.finalize

binding.pry
