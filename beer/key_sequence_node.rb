require 'beer/command'

module Beer

  class KeySequenceNode
    attr_accessor :key, :children, :command, :pre_code, :parent

    def initialize(key, children = [], command = nil)
      @key, @children, @command = key, children, command
      @pre_code = proc {}
    end

    def add_child(child)
      child.parent = self
      @children << child
    end

    def inspect
      "#<KSN:#{object_id} key: #{key.inspect}, children: #{children.inspect}>, command: #{command.inspect}"
    end
  end

end

