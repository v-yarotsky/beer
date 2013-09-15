require 'spec_helper'

module Beer

  describe KeySequenceTreeBuilder do
    let(:command1) { Command.new("command_1", Key("UP"))               { :command_1 } }
    let(:command2) { Command.new("command_2", Key("DOWN"))             { :command_2 } }
    let(:command3) { Command.new("command_3", Key("UP"), Key("LEFT"))  { :command_3 } }
    let(:command4) { Command.new("command_4", Key("UP"), Key("UP"))    { :command_4 } }

    let(:trees) { KeySequenceTreeBuilder.build_trees_from_commands([command1, command2, command3, command4]) }

    it "builds trees from commands list" do
      root_node = KeySequenceNode.new(Key("NO_KEY"))

      expected_trees = [
        KeySequenceNode.new(Key("UP")).tap do |node|
          node.command = command1
          node.add_child(KeySequenceNode.new(Key("LEFT")).tap  { |n| n.command = command3 })
          node.add_child(KeySequenceNode.new(Key("UP")).tap    { |n| n.command = command4 })
        end,
        KeySequenceNode.new(Key("DOWN")).tap { |n| n.command = command2 }
      ].each { |node| root_node.add_child(node) }

      expect(trees).to eq(expected_trees)
    end

  end

end

