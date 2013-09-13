module ZephyrosVlyrs

  class Api
    class Error < StandardError; end

    def initialize(api, options = {})
      @api = api
      @consequent_keys_timeout = options.fetch(:consequent_keys_timeout) { 0.5 }
    end

    def bind_key(key, modifiers = [], &block)
      ZephyrosVlyrs.logger.debug("binding #{key} #{modifiers.inspect}")
      logging_block = proc { |*args| ZephyrosVlyrs.logger.debug("pressed #{key} #{modifiers.inspect}"); block.call(*args) }
      @api.bind(key, modifiers, &logging_block)
    end

    def unbind_key(key, modifiers = [])
      ZephyrosVlyrs.logger.debug("unbinding #{key} #{modifiers.inspect}")
      @api.unbind(key, modifiers)
    end

    def bind_sequence(*keys, &block)
      keys = keys.dup
      key = keys.shift
      started = Time.now
      received = false
      t = Thread.new do
        bind_key(key) { ZephyrosVlyrs.logger.debug("pressed #{key}"); @api.alert(key); received = true }
      end
      elapsed = Time.now - started
      sleep([@consequent_keys_timeout - elapsed, 0].max)
      t.join
      if keys.empty?
        block.call if received
      else
        bind_sequence(*keys, &block)
      end
    ensure
      unbind_key(key)
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

