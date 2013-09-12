require '/Applications/Zephyros.app/Contents/Resources/libs/zephyros.rb'

module ZephyrosVlyrs
  Thread.abort_on_exception = true

  class Mode
    attr_reader :keybinding, :commands

    def initialize(api, options)
      @keybinding = options.fetch(:keybinding).dup.freeze
      @consequent_keys_timeout = 200
      @api = api

      top_half = Command.new("UP") do
        win = @api.focused_window
        screen_frame = win.screen.frame_without_dock_or_menu
        frame = half_top_frame(screen_frame)
        dismiss!
        if consequent_keybinding("LEFT")
          frame = top_left_frame(screen_frame)
        end
        dismiss!
        if consequent_keybinding("RIGHT")
          frame = top_right_frame(screen_frame)
        end
        win.frame = frame
      end

      bottom_half = Command.new("DOWN") do
        win = @api.focused_window
        screen_frame = win.screen.frame_without_dock_or_menu
        frame = half_bottom_frame(screen_frame)
        dismiss!
        if consequent_keybinding("LEFT")
          frame = bottom_left_frame(screen_frame)
        end
        dismiss!
        if consequent_keybinding("RIGHT")
          frame = bottom_right_frame(screen_frame)
        end
        win.frame = frame
      end

      left_half = Command.new("LEFT") do
        win = @api.focused_window
        screen_frame = win.screen.frame_without_dock_or_menu
        frame = half_left_frame(screen_frame)
        dismiss!
        if consequent_keybinding("TOP")
          frame = top_left_frame(screen_frame)
        end
        dismiss!
        if consequent_keybinding("BOTTOM")
          frame = bottom_left_frame(screen_frame)
        end
        win.frame = frame
      end

      right_half = Command.new("RIGHT") do
        win = @api.focused_window
        screen_frame = win.screen.frame_without_dock_or_menu
        frame = half_right_frame(screen_frame)
        dismiss!
        if consequent_keybinding("TOP")
          frame = top_right_frame(screen_frame)
        end
        dismiss!
        if consequent_keybinding("BOTTOM")
          frame = bottom_right_frame(screen_frame)
        end
        win.frame = frame
      end

      maximize = Command.new("RETURN") do
        win = @api.focused_window
        frame = win.screen.frame_without_dock_or_menu
        win.frame = frame
      end

      dismiss = Command.new("ESCAPE") {}

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

    def half_left_frame(screen_frame)
      frame = screen_frame.dup
      frame.w /= 2
      frame
    end

    def half_top_frame(screen_frame)
      frame = screen_frame.dup
      frame.h /= 2
      frame
    end

    def half_right_frame(screen_frame)
      frame = screen_frame.dup
      frame.w /= 2
      frame.x = frame.w
      frame
    end

    def half_bottom_frame(screen_frame)
      frame = screen_frame.dup
      frame.h /= 2
      frame.y = frame.h
      frame
    end

    def top_left_frame(screen_frame)
      frame = screen_frame.dup
      frame.h /= 2
      frame.w /= 2
      frame
    end

    def top_right_frame(screen_frame)
      frame = screen_frame.dup
      frame.h /= 2
      frame.w /= 2
      frame.x = frame.x
      frame
    end

    def bottom_left_frame(screen_frame)
      frame = screen_frame.dup
      frame.h /= 2
      frame.w /= 2
      frame.y = frame.h
      frame
    end

    def bottom_right_frame(screen_frame)
      frame = screen_frame.dup
      frame.h /= 2
      frame.w /= 2
      frame.y = frame.h
      frame.x = frame.w
      frame
    end

    def activate!
      @api.show_box("Doing magic!")
      @commands.each do |cmd|
        @api.bind cmd.key, cmd.mash do
          cmd.code.call
          dismiss!
        end
      end
    end

    def dismiss!
      @commands.each { |cmd| @api.unbind cmd.key, cmd.mash }
      @api.hide_box
    end
  end

  class Command
    attr_reader :key, :mash, :code

    def initialize(key, mash = [], &block)
      @key = key.dup.freeze
      @mash = mash.dup.freeze
      @code = block
    end
  end
end

mode = ZephyrosVlyrs::Mode.new(API, :keybinding => ["F13", ["Shift"]])

API.bind *mode.keybinding do
  mode.activate!
end

wait_on_callbacks

