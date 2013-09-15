module Beer

  class KeySequenceNode
    attr_accessor :key, :children, :command, :pre_code, :parent

    # @key [Key]
    # @children [Array<KeySequenceNode>]
    # @command [NilClass, Command]
    #
    def initialize(key, children = [], command = nil)
      @key, @children, @command = key, children, command
      @pre_code = proc {}
    end

    # This method should be used instead of modifying #children directly
    #
    def add_child(child)
      child.parent = self
      @children << child
    end

    def inspect
      "#<KSN:#{object_id} key: #{key.inspect}, children: #{children.inspect}>, command: #{command.inspect}"
    end
  end

end

