$:.unshift("/Applications/Zephyros.app/Contents/Resources/libs")
$:.unshift(File.dirname(__FILE__))
require 'zephyros'
require 'zephyros_vlyrs/api'
require 'zephyros_vlyrs/command'
require 'zephyros_vlyrs/key_sequence_node'
require 'zephyros_vlyrs/key_sequence_leaf'
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

      top_left_quarter = Command.new("top_left_quarter", "UP", "LEFT") do |win, screen_frame, api|
        win.frame = screen_frame.top_left_quarter_rect
      end

      maximize = Command.new("maximize", "RETURN") do |win, screen_frame, api|
        win.frame = screen_frame
      end

      dismiss = Command.new("dismiss", "ESCAPE") {}

      @keys_tree = build_key_sequences_tree([
        top_left_quarter,
        left_half,
        right_half,
        bottom_half
      ])
    end

    def build_key_sequences_tree(commands)
      current_node = KeySequenceNode.new(@mode_keybinding, [])
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
            new_node = command.keys == processed_keys ? KeySequenceLeaf.new(key, command) : KeySequenceNode.new(key)
            current_node.add_child new_node
            current_node = new_node
          end
        end
        current_node = root_node
      end
      root_node
    end

    def bind_keys_tree(keys_tree)
      @api.bind_key *keys_tree.key do
        keys_tree.pre_code.call
        if keys_tree.parent
          keys_tree.parent.children.each { |c| @api.unbind_key *c.key }
        else
          @api.unbind_key *keys_tree.key
        end
        if keys_tree.is_a?(KeySequenceLeaf)
          execute_command(keys_tree.command)
        elsif keys_tree.is_a?(KeySequenceNode)
          p keys_tree.children
          keys_tree.children.each { |c| bind_keys_tree(c) }
        else
          raise "Something went wrong with tree"
        end
      end
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
      bind_keys_tree(@keys_tree)
    end
  end
end

api = ZephyrosVlyrs::Api.new(API)
mode = ZephyrosVlyrs::Mode.new(api, :mode_keybinding => ["F13", ["Shift"]])

mode.activate!
wait_on_callbacks

=begin

Notes on key sequences

two sequences can begin with same key, therefore plain recursive approach with timers does not work here,
I need to build some data structure here

like, for sequences:

UP, LEFT
UP, RIGHT
LEFT, LEFT
RIGHT, RIGHT

it is

    UP        LEFT    RIGHT
   /  \        |        |
LEFT RIGHT    LEFT    RIGHT

if stumbled upon sequence with both continuation and leaf (command) - run command if sequence is not continued
within given timeout

=end
