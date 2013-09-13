module ZephyrosVlyrs

  class Command
    attr_reader :name, :keys, :code

    def initialize(name, *keys, &block)
      @name = name.dup.freeze
      @keys = keys.dup.freeze
      @code = block
    end

    def inspect
      "#<%s:%x %s %s" % [self.class.name, object_id, @name, @keys.inspect]
    end
  end

end

