module Beer
  module Modes

    class BaseMode
      def initialize(api, options)
        @mode_key = Key(options.fetch("mode_key"))
        @key_sequence_timeout = options.fetch("key_sequence_timeout")
        @api = api
        @keys_tree = KeySequenceTreeBuilder.build_from_commands(supported_commands)
        @keys_tree.key = @mode_key
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
        @keys_tree.pre_code = method(:on_activate)
        bind_keys_tree(@keys_tree)
      end

      def bind_keys_tree(tree, &block)
        @api.bind_key tree.key do
          block.call if block # notify bound key was pressed
          tree.pre_code.call
          tree.parent.children.each { |c| @api.unbind_key c.key }
          if tree.command && !tree.children.empty? # we have a command and continued sequence on the same key
            resolve_binding_conflict(tree)
          elsif tree.command
            execute_command(tree.command)
          elsif !tree.children.empty?
            bind_children(tree)
          end
        end
      end
      private :bind_keys_tree

      # If one of children was triggered during some period  - go on with sequence, else run command
      #
      def resolve_binding_conflict(tree)
        child_triggered = false
        Utils::TimedThread.new(@key_sequence_timeout) do
          bind_children(tree) { child_triggered = true }
        end
        Beer.logger.debug("child_triggered: #{child_triggered}")
        unless child_triggered
          execute_command(tree.command)
        end
      end
      private :resolve_binding_conflict

      def execute_command(command)
        Beer.logger.debug(command.name)
        window = @api.focused_window
        command.code.call(window, @api)
        dismiss!
      end
      private :execute_command

      def bind_children(tree, &block)
        tree.children.each { |c| bind_keys_tree(c, &block) }
      end
      private :bind_children

      def dismiss!
        Beer.logger.debug("dismissing")
        @api.dismiss_bindings!
        on_deactivate
        bind_keys_tree(@keys_tree)
      end

    end

  end
end

