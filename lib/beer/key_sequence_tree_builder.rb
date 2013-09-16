module Beer

  class KeySequenceTreeBuilder
    class << self
      def build_trees_from_commands(commands)
        root_node = KeySequenceNode.new(Key("NO_KEY"))

        commands.each { |command| build_nodes_for_command(root_node, command) }
        root_node.children
      end

      def build_nodes_for_command(root_node, command)
        current_node = root_node
        processed_keys = []
        command.keys.each do |key|
          processed_keys.push(key)
          matching_node = current_node.children.detect { |c| c.key == key }
          if matching_node
            current_node = matching_node
          else
            new_node = KeySequenceNode.new(key)
            if command.keys == processed_keys
              new_node.command = command
            end
            current_node.add_child new_node
            current_node = new_node
          end
        end
      end
      private :build_nodes_for_command
    end
  end

end
