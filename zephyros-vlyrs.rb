require '/Applications/Zephyros.app/Contents/Resources/libs/zephyros.rb'
require 'logger'
require 'delegate'

module ZephyrosVlyrs
  Thread.abort_on_exception = true

  class << self
    def logger
      @logger ||= Logger.new(ENV["DEBUG"] ? "/tmp/zephyros-vlyrs.log" : "/dev/null")
    end
  end

  class Mode
    attr_reader :keybinding, :commands

    def initialize(api, options)
      @keybinding = options.fetch(:keybinding).dup.freeze
      @consequent_keys_timeout = 200
      @api = api

      top_half = Command.new("top_half", "UP") do |win, screen_frame, api|
        win.frame = screen_frame.half_top_rect
      end

      bottom_half = Command.new("bottom_half", "DOWN") do |win, screen_frame, api|
        win.frame = screen_frame.half_bottom_rect
      end

      left_half = Command.new("left_half", "LEFT") do |win, screen_frame, api|
        win.frame = screen_frame.half_left_rect
      end

      right_half = Command.new("right_half", "RIGHT") do |win, screen_frame, api|
        win.frame = screen_frame.half_right_rect
      end

      maximize = Command.new("maximize", "RETURN") do |win, screen_frame, api|
        win.frame = screen_frame
      end

      dismiss = Command.new("dismiss", "ESCAPE") {}

      @commands = [top_half, bottom_half, left_half, right_half, maximize, dismiss]
    end

    def consequent_keybinding(*keys)
      key = keys.first
      started = Time.now
      received = false
      t = Thread.new do
        @api.bind(key, []) { @api.alert(key); received = true }
      end
      elapsed = Time.now - started
      sleep([@consequent_keys_timeout.to_f / 1000 - elapsed, 0].max)
      t.join
      if keys.size == 1
        return received
      else
        return consequent_keybinding(keys[1..-1])
      end
    ensure
      @api.unbind(key, [])
    end

    def activate!
      @api.show_box("Doing magic!")
      bind_commands
    end

    def bind_commands
      ZephyrosVlyrs.logger.debug("binding commands: #{@commands.map(&:inspect).join(", ")}")
      window = @api.focused_window
      screen_frame = TransformableRect.new(window.screen.frame_without_dock_or_menu)
      @commands.each do |cmd|
        @api.bind cmd.key, cmd.mash do
          ZephyrosVlyrs.logger.debug("#{cmd.name}, frame: #{screen_frame.inspect}")
          cmd.code.call(window, screen_frame, @api)
          dismiss!
        end
      end
    end
    private :bind_commands

    def dismiss!
      ZephyrosVlyrs.logger.debug("dismissing")
      @commands.each { |cmd| @api.unbind cmd.key, cmd.mash }
      @api.hide_box
    end
  end

  class Command
    attr_reader :name, :key, :mash, :code

    def initialize(name, key, mash = [], &block)
      @name = name.dup.freeze
      @key = key.dup.freeze
      @mash = mash.dup.freeze
      @code = block
    end

    def inspect
      "#<%s:%x %s %s %s" % [self.class.name, object_id, @name, @key.inspect, @mash.inspect]
    end
  end

  class TransformableRect < DelegateClass(Rect)
    def initialize(rect)
      super(rect)
      @rect = rect
    end

    def half_left_rect
      make_rect(@rect.dup.tap { |r| r.w /= 2 })
    end

    def half_top_rect
      make_rect(@rect.dup.tap { |r| r.h /= 2 })
    end

    def half_right_rect
      make_rect(@rect.dup.tap { |r| r.w /= 2; r.x += r.w })
    end

    def half_bottom_rect
      make_rect(@rect.dup.tap { |r| r.h /= 2; r.y += r.h })
    end

    def top_left_rect
      make_rect(@rect.dup.tap { |r| r.h /= 2; r.w /= 2 })
    end

    def top_right_rect
      make_rect(@rect.dup.tap { |r| r.h /= 2; r.w /= 2; r.x += r.w })
    end

    def bottom_left_rect
      make_rect(@rect.dup.tap { |r| r.h /= 2; r.w /= 2; r.y += r.h })
    end

    def bottom_right_rect
      make_rect(@rect.dup.tap { |r| r.h /= 2; r.w /= 2; r.x += r.w; r.y += r.h })
    end

    def make_rect(rect)
      self.class.new(rect)
    end
    private :make_rect
  end

  class Api
    class Error < StandardError; end

    def initialize(api)
      @api = api
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

api = ZephyrosVlyrs::Api.new(API)
mode = ZephyrosVlyrs::Mode.new(api, :keybinding => ["F13", ["Shift"]])

api.bind *mode.keybinding do
  mode.activate!
end


wait_on_callbacks

