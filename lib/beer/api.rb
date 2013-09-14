require 'beer/key'
require 'set'

module Beer

  class Api
    class Error < StandardError; end

    def initialize(api, options = {})
      @api = api
      @bound_keys = Set.new
    end

    # binds [Key] to the given block
    # @key [Key]
    #
    def bind_key(key, &block)
      Beer.logger.debug("binding #{key}")
      logging_block = proc { |*args| Beer.logger.debug("pressed #{key}"); block.call(*args) }
      @api.bind(*key, &logging_block)
      @bound_keys.add(key)
    end

    # @key [Key]
    #
    def unbind_key(key)
      Beer.logger.debug("unbinding #{key}")
      @api.unbind(*key)
      @bound_keys.delete(key)
    end

    # Only works for keys bound with #bind_key
    def dismiss_bindings!
      @bound_keys.dup.each do |key|
        unbind_key(key)
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

