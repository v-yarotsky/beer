module Beer

  class KeySequenceNode
    attr_accessor :key, :children, :command, :parent

    # @key [Key]
    #
    def initialize(key)
      @key = key
      @children = []
      @command = nil
    end

    # This method should be used instead of modifying #children directly
    #
    def add_child(child)
      child.parent = self
      @children << child
    end

    def ==(other)
      return true if other.equal?(self)
      return other.key == key &&
             other.command == command &&
             other.children == children &&
             other.parent == parent
    end

    def inspect
      "#<KSN:#{object_id} key: #{key}, children: #{children.inspect}>, command: #{command.inspect}, parent_key: #{parent.key if parent}"
    end
  end

end

