require 'data_mapper'
require 'json'
require 'yaml'
require 'pry'

Dir.glob("models/*.rb").each {|x| require_relative x}

config = JSON.parse(File.read("database_config.json"))
DataMapper.setup(:default, config)
DataMapper.finalize

binding.pry
