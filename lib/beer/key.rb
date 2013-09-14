module Beer

  class Key
    ALLOWED_MODIFIERS = %W(SHIFT ALT CTRL CMD)
    JOIN = "+"

    attr_reader :key, :modifiers

    def initialize(key_str)
      *@modifiers, @key = key_str.to_s.upcase.gsub(/\s+/, "").split(JOIN)
      validate_modifiers!
      validate_key!
    end

    def validate_modifiers!
      unknown_modifiers = @modifiers - ALLOWED_MODIFIERS
      unless unknown_modifiers.empty?
        raise ArgumentError, "Unknown modifiers: #{@modifiers.inspect}. Allowed: #{ALLOWED_MODIFIERS.inspect}"
      end
    end
    private :validate_modifiers!

    def validate_key!
      if ALLOWED_MODIFIERS.include?(@key)
        raise ArgumentError, "Main key must be non-modifier"
      end
    end
    private :validate_key!

    def to_a
      [@key, @modifiers]
    end

    def inspect
      "#<%s:%x %s>" % [self.class.name, object_id, [*@modifiers, @key].join(JOIN)]
    end

    def ==(other)
      return true if other.equal?(self)
      return true if other.key == key && other.modifiers == modifiers
      false
    end
  end

end

def Key(key_str)
  Beer::Key.new(key_str)
end

