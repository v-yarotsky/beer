require 'beer/mode'
require 'yaml'
require 'logger'

module Beer
  CONFIG_PATH = File.expand_path("~/.beer.yml").freeze

  def self.config
    @config ||= File.exists?(CONFIG_PATH) ? YAML.load(File.read(CONFIG_PATH)) : {}
  end

  def self.logger
    @logger ||= Logger.new(ENV["DEBUG"] ? config.fetch("log") { "/tmp/beer.log" } : "/dev/null")
  end

end

