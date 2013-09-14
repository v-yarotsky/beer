require 'zephyros'
require 'beer/key'
require 'beer/api'
require 'beer/command'
require 'beer/key_sequence_tree_builder'
require 'beer/transformable_rect'
require 'beer/timed_thread'

module Beer

  class Mode
    Thread.abort_on_exception = true

    def initialize(api, options)
      @mode_key = Key(options.fetch("mode_key") { "Shift+F13" })
      @key_sequence_timeout = options.fetch("key_sequence_timeout") { 0.15 }
      @api = api

      move_window_to_screen = proc do |window, target_screen|
        frame = target_screen.frame_without_dock_or_menu
        frame.w = [frame.w, window.frame.w].min
        frame.h = [frame.h, window.frame.h].min
        window.frame = frame
      end

      @keys_tree = KeySequenceTreeBuilder.build_from_commands([
        Command.new("left_half",             Key("Left"))                { |win, screen_frame| win.frame = screen_frame.half_left_rect },
        Command.new("top_half",              Key("Up"))                  { |win, screen_frame| win.frame = screen_frame.half_top_rect },
        Command.new("right_half",            Key("Right"))               { |win, screen_frame| win.frame = screen_frame.half_right_rect },
        Command.new("bottom_half",           Key("Down"))                { |win, screen_frame| win.frame = screen_frame.half_bottom_rect },
        Command.new("top_left_quarter",      Key("Up"), Key("Left") )    { |win, screen_frame| win.frame = screen_frame.top_left_quarter_rect },
        Command.new("top_right_quarter",     Key("Up"), Key("Right"))    { |win, screen_frame| win.frame = screen_frame.top_right_quarter_rect },
        Command.new("bottom_right_quarter",  Key("Down"), Key("Right"))  { |win, screen_frame| win.frame = screen_frame.bottom_right_quarter_rect },
        Command.new("bottom_left_quarter",   Key("Down"), Key("Left"))   { |win, screen_frame| win.frame = screen_frame.bottom_left_quarter_rect },
        Command.new("maximize",              Key("Return"))              { |win, screen_frame| win.frame = screen_frame },
        Command.new("move_to_left_screen",   Key("Left"), Key("Left"))   { |win| move_window_to_screen[win, win.screen.previous_screen] },
        Command.new("move_to_right_screen",  Key("Right"), Key("Right")) { |win| move_window_to_screen[win, win.screen.next_screen] },
        Command.new("focus_window_left",     Key("a"))                   { |win| win.focus_window_left },
        Command.new("focus_window_up",       Key("w"))                   { |win| win.focus_window_up },
        Command.new("focus_window_right",    Key("d"))                   { |win| win.focus_window_right },
        Command.new("focus_window_down",     Key("s"))                   { |win| win.focus_window_down },
        Command.new("dismiss",               Key("Escape"))              {}
      ])

      @keys_tree.key = @mode_key
      @keys_tree.pre_code = proc { @api.show_box("Magic!") }
    end

    def bind_keys_tree(tree, &block)
      @api.bind_key tree.key do
        block.call if block # notify bound key was pressed
        tree.pre_code.call
        if tree.parent
          tree.parent.children.each { |c| @api.unbind_key c.key }
        else
          @api.unbind_key tree.key
        end
        if tree.command && !tree.children.empty? # we have a command and continued sequence on the same key
          # if one of children was triggered during some period (how to know?) - go on, else run command
          child_triggered = false
          TimedThread.new(@key_sequence_timeout) do
            tree.children.each { |c| bind_keys_tree(c) { child_triggered = true } }
          end
          Beer.logger.debug("child_triggered: #{child_triggered}")
          unless child_triggered
            execute_command(tree.command)
          end
        elsif tree.command && tree.children.empty?
          execute_command(tree.command)
        elsif !tree.command & !tree.children.empty?
          tree.children.each { |c| bind_keys_tree(c) }
        end
      end
    end

    def execute_command(command)
      window = @api.focused_window
      screen_frame = TransformableRect.new(window.screen.frame_without_dock_or_menu)
      Beer.logger.debug("#{command.name}, frame: #{screen_frame.inspect}")
      command.code.call(window, screen_frame, @api)
      dismiss!
    end

    def activate!
      bind_keys_tree(@keys_tree)
    end

    def dismiss!
      Beer.logger.debug("dismissing")
      @api.hide_box
      @api.dismiss_bindings!
      bind_keys_tree(@keys_tree)
    end
  end

end

