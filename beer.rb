$:.unshift("/Applications/Zephyros.app/Contents/Resources/libs")
$:.unshift(File.dirname(__FILE__))
require 'zephyros'
require 'beer/api'
require 'beer/command'
require 'beer/key_sequence_tree_builder'
require 'beer/transformable_rect'
require 'beer/timed_thread'
require 'logger'

module Beer
  Thread.abort_on_exception = true

  class << self
    def logger
      @logger ||= Logger.new(ENV["DEBUG"] ? "/tmp/beer.log" : "/dev/null")
    end
  end

  class Mode
    def initialize(api, options)
      @mode_keybinding = options.fetch(:mode_keybinding).dup.freeze
      @consequent_keys_timeout = options.fetch(:consequent_keys_timeout) { 0.1 }
      @api = api

      @keys_tree = KeySequenceTreeBuilder.build_from_commands([
        Command.new("left_half",            "LEFT")          { |win, screen_frame| win.frame = screen_frame.half_left_rect },
        Command.new("top_half",             "UP")            { |win, screen_frame| win.frame = screen_frame.half_top_rect },
        Command.new("right_half",           "RIGHT")         { |win, screen_frame| win.frame = screen_frame.half_right_rect },
        Command.new("bottom_half",          "DOWN")          { |win, screen_frame| win.frame = screen_frame.half_bottom_rect },
        Command.new("top_left_quarter",     "UP", "LEFT")    { |win, screen_frame| win.frame = screen_frame.top_left_quarter_rect },
        Command.new("top_right_quarter",    "UP", "RIGHT")   { |win, screen_frame| win.frame = screen_frame.top_right_quarter_rect },
        Command.new("bottom_right_quarter", "DOWN", "RIGHT") { |win, screen_frame| win.frame = screen_frame.bottom_right_quarter_rect },
        Command.new("bottom_left_quarter",  "DOWN", "LEFT")  { |win, screen_frame| win.frame = screen_frame.bottom_left_quarter_rect },
        Command.new("maximize",             "RETURN")        { |win, screen_frame| win.frame = screen_frame },
        Command.new("dismiss",              "ESCAPE")        {}
      ])

      @keys_tree.key = @mode_keybinding
      @keys_tree.pre_code = proc { @api.show_box("Magic!") }
    end

    def bind_keys_tree(tree, &block)
      @api.bind_key *tree.key do
        block.call if block # notify bound key was pressed
        tree.pre_code.call
        if tree.parent
          tree.parent.children.each { |c| @api.unbind_key *c.key }
        else
          @api.unbind_key *tree.key
        end
        if tree.command && !tree.children.empty? # we have a command and continued sequence on the same key
          # if one of childs was triggered during some period (how to know?) - go on, else run command
          child_triggered = false
          TimedThread.new(@consequent_keys_timeout) do
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

api = Beer::Api.new(API)
mode = Beer::Mode.new(api, :mode_keybinding => ["F13", ["Shift"]])

mode.activate!
wait_on_callbacks

