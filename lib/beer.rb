require 'yaml'
require 'logger'

module Beer
  CONFIG_PATH = File.expand_path("~/.beer.yml").freeze

  def self.config
    @config ||= begin
      config = default_config
      if File.exists?(CONFIG_PATH)
        config.merge!(YAML.load(File.read(CONFIG_PATH)))
      end
      config
    end
  end

  def self.default_config
    {
      "mode_key"             => "Ctrl+Alt+W",
      "key_sequence_timeout" => 0.15,
      "log"                  => "/tmp/beer.log",
      "auto_dismiss"         => true
    }
  end

  def self.logger
    @logger ||= Logger.new(ENV["DEBUG"] ? config.fetch("log") { "/tmp/beer.log" } : "/dev/null")
  end

  # Eager requires
  require 'beer/key'

  # Lazy requires
  autoload :Api,                    'beer/api'
  autoload :Command,                'beer/command'
  autoload :KeySequenceNode,        'beer/key_sequence_node'
  autoload :KeySequenceTreeBuilder, 'beer/key_sequence_tree_builder'
  autoload :Modes,                  'beer/modes'
  autoload :Utils,                  'beer/utils'
end

