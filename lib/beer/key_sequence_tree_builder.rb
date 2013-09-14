require 'beer/key_sequence_node'
require 'beer/key'

module Beer

  class KeySequenceTreeBuilder
    class << self
      def build_from_commands(commands)
        root_node = KeySequenceNode.new(Key("no_key"))
        commands.each { |command| build_nodes_for_command(root_node, command) }
        root_node
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
            new_node = KeySequenceNode.new(key, [], (command if command.keys == processed_keys))
            current_node.add_child new_node
            current_node = new_node
          end
        end
      end
      private :build_nodes_for_command
    end
  end

end
