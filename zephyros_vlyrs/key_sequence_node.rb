module ZephyrosVlyrs

  class KeySequenceNode
    attr_accessor :key, :children, :pre_code, :parent

    def initialize(key, children = [])
      @key, @children = key, children
      @pre_code = proc {}
    end

    def add_child(child)
      child.parent = self
      @children << child
    end

    def inspect
      "#<KSN:#{object_id} key: #{key.inspect}, children = #{children.inspect}>"
    end
  end

end

