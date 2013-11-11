require 'thread'

module Beer
  module Modes

    class BaseMode
      def initialize(api, options)
        @mode_key = Key(options.fetch("mode_key"))
        @key_sequence_timeout = options.fetch("key_sequence_timeout")
        @auto_dismiss = options.fetch("auto_dismiss")
        @api = api
        @key_trees = KeySequenceTreeBuilder.build_trees_from_commands(supported_commands)
        @active = false
        @event_lock = Mutex.new
      end

      def run_ticker
        return if @ticker && @ticker.alive?
        @ticker = Thread.new do
          loop do
            sleep 0.05
            on_event(:tick)
          end
        end
      end

      # To be implemented in descendants
      #
      def supported_commands
        []
      end

      # To be implemented in descendants
      #
      def on_activate
      end

      # To be implemented in descendants
      #
      def on_deactivate
      end

      def activate!
        run_ticker
        @api.bind_key(@mode_key) do
          @api.unbind_key(@mode_key)
          on_activate
          @active = true
          bind_first_keys
        end
      end

      def dismiss!
        Beer.logger.debug("dismissing")
        @active = false
        on_deactivate
        activate!
      end

      private

      def bind_first_keys
        if @active
          @key_trees.each { |tree| bind_keys_for_tree(tree) }
        end
      end

      def on_event(event, node = nil)
        @event_lock.synchronize do
          current_time = Time.now

          case event
          when :keypress
            unbind_keys_for_trees(node.parent.children)
            if late?(current_time)
              run_node_command(@prev_node)
            else
              do_before_timeout_or_for_the_first_time(node, current_time)
            end
          when :tick
            if @prev_node && late?(current_time)
              unbind_keys_for_trees(@prev_node.children)
              run_node_command(@prev_node)
            end
          end
        end
      end

      def late?(current_time)
        @key_pressed_at && (current_time - @key_pressed_at) > @key_sequence_timeout
      end

      def bind_keys_for_tree(node)
        @api.bind_key node.key do
          on_event(:keypress, node)
        end
      end

      def unbind_keys_for_trees(trees)
        trees.each { |tree| @api.unbind_key(tree.key) }
      end

      def run_node_command(node)
        if node.command
          execute_command(node.command)
        else
          Beer.logger.debug("Do nothing - how did I get here?")
        end
        @key_pressed_at = nil
        @prev_node = nil
        @auto_dismiss ? dismiss! : bind_first_keys
      end

      def execute_command(command)
        Beer.logger.debug(command.name)
        window = @api.focused_window
        command.call(window, @api)
      end

      def do_before_timeout_or_for_the_first_time(node, current_time)
        if node.children.any?
          if node.command
            @key_pressed_at = current_time
            @prev_node = node
          end
          node.children.each { |c| bind_keys_for_tree(c) }
        else
          run_node_command(node)
        end
      end

      # TODO remove?
      def unbind_first_keys
        unbind_keys_for_trees(@key_trees)
      end
    end

  end
end

