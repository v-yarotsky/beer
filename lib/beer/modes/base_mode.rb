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
        @api.bind_key(@mode_key) do
          on_activate
          @active = true
          bind_first_keys
        end
      end

      def bind_first_keys
        if @active
          @key_trees.each { |tree| bind_keys_for_tree(tree) }
        end
      end
      private :bind_first_keys

      def bind_keys_for_tree(node, &block)
        @api.bind_key node.key do
          block.call if block # notify bound key was pressed
          unbind_keys_for_trees(node.parent.children)
          bind_with_conflict_resolving(node)
        end
      end
      private :bind_keys_for_tree

      def unbind_first_keys
        unbind_keys_for_trees(@key_trees)
      end
      private :unbind_first_keys

      def unbind_keys_for_trees(trees)
        trees.each { |tree| @api.unbind_key(tree.key) }
      end
      private :unbind_keys_for_trees

      # If one of children was triggered during some period  - go on with sequence, else run command
      #
      def bind_with_conflict_resolving(tree)
        child_triggered = false
        Utils::TimedThread.new(@key_sequence_timeout) do
          tree.children.each { |c| bind_keys_for_tree(c) { child_triggered = true } }
        end
        Beer.logger.debug("child_triggered: #{child_triggered}")
        if tree.command && !child_triggered
          execute_command(tree.command)
        end
      end
      private :bind_with_conflict_resolving

      def execute_command(command)
        Beer.logger.debug(command.name)
        window = @api.focused_window
        command.call(window, @api)
        unbind_first_keys
        @auto_dismiss ? dismiss! : bind_first_keys
      end
      private :execute_command

      def dismiss!
        Beer.logger.debug("dismissing")
        @api.unbind_key(@mode_key)
        @active = false
        on_deactivate
        activate!
      end

    end

  end
end

