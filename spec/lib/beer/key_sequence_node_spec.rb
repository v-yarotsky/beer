require 'spec_helper'

module Beer

  describe KeySequenceNode do
    subject(:node) { KeySequenceNode.new(Key("A")) }

    it "is has no children initially" do
      expect(node.children).to be_empty
    end

    context "children nodes" do
      let(:child_node) { KeySequenceNode.new(Key("B")) }

      it "sets child's parent to self" do
        node.add_child(child_node)
        expect(child_node.parent).to equal(node)
      end

      it "adds child node to parent's children list" do
        node.add_child(child_node)
        expect(node.children).to include(child_node)
      end
    end

    context "equality" do
      it "is == to self" do
        expect(node).to eq(node)
      end

      it "is == if key, children, and command are same" do
        expect(node).to eq(KeySequenceNode.new(Key("A")))
      end

      it "is is not == if key differs" do
        expect(node).not_to eq(KeySequenceNode.new(Key("b")))
      end

      it "is is not == if key differs" do
        child_node = KeySequenceNode.new(Key("B"))
        node.add_child(child_node)
        other_node = KeySequenceNode.new(Key("A"))
        expect(node).not_to eq(other_node)
      end

      it "is not == if parent differs" do
        parent = KeySequenceNode.new(Key("B"))
        node.parent = parent
        other_node = KeySequenceNode.new(Key("A"))
        expect(node).not_to eq(other_node)
      end

      it "is not == if command differs" do
        node.command = :some_command_instance
        other_node = KeySequenceNode.new(Key("A"))
        expect(node).not_to eq(other_node)
      end
    end

    it "has meaningful #inspect" do
      expect(node.inspect).to match(/key:.*children.*command.*parent_key.*/)
    end
  end

end

