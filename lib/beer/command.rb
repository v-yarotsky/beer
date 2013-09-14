module Beer

  class Command
    attr_reader :name, :keys, :code

    # @name [String] command name (for log)
    # @keys [Array<Key>] sequence of trigger keys
    #
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

