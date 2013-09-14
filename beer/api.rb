require 'set'

module Beer

  class Api
    class Error < StandardError; end

    def initialize(api, options = {})
      @api = api
      @bound_keys = Set.new
    end

    def bind_key(key, modifiers = [], &block)
      Beer.logger.debug("binding #{key} #{modifiers.inspect}")
      logging_block = proc { |*args| Beer.logger.debug("pressed #{key} #{modifiers.inspect}"); block.call(*args) }
      @api.bind(key, modifiers, &logging_block)
      @bound_keys.add([key, modifiers])
    end

    def unbind_key(key, modifiers = [])
      Beer.logger.debug("unbinding #{key} #{modifiers.inspect}")
      @api.unbind(key, modifiers)
      @bound_keys.delete([key, modifiers])
    end

    # Only works for keys bound with #bind_key
    def dismiss_bindings!
      @bound_keys.dup.each do |(key, modifiers)|
        unbind_key(key, modifiers)
      end
    end

    def method_missing(method_name, *args, &block)
      @api.send(method_name, *args, &block)
    rescue RuntimeError => e
      error = Error.new(e)
      error.set_backtrace(e.backtrace)
      raise error
    end
  end

end

