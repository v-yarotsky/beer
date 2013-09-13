require 'zephyros_vlyrs/key_sequence_node'

module ZephyrosVlyrs

  class KeySequenceLeaf < KeySequenceNode
    attr_accessor :command

    def initialize(key, command)
      @command = command
      super(key, [])
    end
  end

end

