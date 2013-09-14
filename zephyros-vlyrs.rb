$:.unshift("/Applications/Zephyros.app/Contents/Resources/libs")
$:.unshift(File.dirname(__FILE__))
require 'zephyros'
require 'zephyros_vlyrs/api'
require 'zephyros_vlyrs/command'
require 'zephyros_vlyrs/key_sequence_node'
require 'zephyros_vlyrs/transformable_rect'
require 'logger'

module ZephyrosVlyrs
  Thread.abort_on_exception = true

  class << self
    def logger
      @logger ||= Logger.new(ENV["DEBUG"] ? "/tmp/zephyros-vlyrs.log" : "/dev/null")
    end
  end

  class Mode
    def initialize(api, options)
      @mode_keybinding = options.fetch(:mode_keybinding).dup.freeze
      @consequent_keys_timeout = 0.1
      @api = api

      left_half = Command.new("left_half", "LEFT") do |win, screen_frame, api|
        win.frame = screen_frame.half_left_rect
      end

      top_half = Command.new("top_half", "UP") do |win, screen_frame, api|
        win.frame = screen_frame.half_top_rect
      end

      right_half = Command.new("right_half", "RIGHT") do |win, screen_frame, api|
        win.frame = screen_frame.half_right_rect
      end

      bottom_half = Command.new("bottom_half", "DOWN") do |win, screen_frame, api|
        win.frame = screen_frame.half_bottom_rect
      end

      top_left_quarter = Command.new("top_left_quarter", "UP", "LEFT") do |win, screen_frame, api|
        win.frame = screen_frame.top_left_quarter_rect
      end

      top_right_quarter = Command.new("top_right_quarter", "UP", "RIGHT") do |win, screen_frame, api|
        win.frame = screen_frame.top_right_quarter_rect
      end

      bottom_right_quarter = Command.new("bottom_right_quarter", "DOWN", "RIGHT") do |win, screen_frame, api|
        win.frame = screen_frame.bottom_right_quarter_rect
      end

      bottom_left_quarter = Command.new("bottom_left_quarter", "DOWN", "LEFT") do |win, screen_frame, api|
        win.frame = screen_frame.bottom_left_quarter_rect
      end

      maximize = Command.new("maximize", "RETURN") do |win, screen_frame, api|
        win.frame = screen_frame
      end

      dismiss = Command.new("dismiss", "ESCAPE") {}

      @keys_tree = build_key_sequences_tree([
        left_half,
        top_half,
        right_half,
        bottom_half,
        top_left_quarter,
        top_right_quarter,
        bottom_right_quarter,
        bottom_left_quarter,
        maximize,
        dismiss
      ])
    end

    def build_key_sequences_tree(commands)
      current_node = KeySequenceNode.new(@mode_keybinding)
      current_node.pre_code = proc { @api.show_box("Magic!") }
      root_node = current_node
      commands.each do |command|
        processed_keys = []
        command.keys.each do |key|
          processed_keys.push(key)
          matching_node = current_node.children.detect { |c| c.key == key }
          if matching_node
            current_node = matching_node
          else
            new_node = KeySequenceNode.new(key, [], (command if command.keys == processed_keys))
            current_node.add_child new_node
            current_node = new_node
          end
        end
        current_node = root_node
      end
      root_node
    end

    def bind_keys_tree(tree, &block)
      @api.bind_key *tree.key do
        block.call if block
        tree.pre_code.call
        if tree.parent
          tree.parent.children.each { |c| @api.unbind_key *c.key }
        else
          @api.unbind_key *tree.key
        end
        if tree.command && !tree.children.empty? # we have a command and continued sequence on the same key
          # if one of childs was triggered during some period (how to know?) - go on, else run command
          child_triggered = false
          timed_thread do
            tree.children.each { |c| bind_keys_tree(c) { child_triggered = true } }
          end
          ZephyrosVlyrs.logger.debug("child_triggered: #{child_triggered}")
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

    def timed_thread(&block)
      started = Time.now
      t = Thread.new(&block)
      elapsed = Time.now - started
      sleep([@consequent_keys_timeout - elapsed, 0].max)
      t.join
    end

    def execute_command(command)
      window = @api.focused_window
      screen_frame = TransformableRect.new(window.screen.frame_without_dock_or_menu)
      ZephyrosVlyrs.logger.debug("#{command.name}, frame: #{screen_frame.inspect}")
      command.code.call(window, screen_frame, @api)
      dismiss!
    end

    def activate!
      bind_keys_tree(@keys_tree)
    end

    def dismiss!
      ZephyrosVlyrs.logger.debug("dismissing")
      @api.hide_box
      @api.dismiss_bindings!
      bind_keys_tree(@keys_tree)
    end
  end
end

api = ZephyrosVlyrs::Api.new(API)
mode = ZephyrosVlyrs::Mode.new(api, :mode_keybinding => ["F13", ["Shift"]])

mode.activate!
wait_on_callbacks

