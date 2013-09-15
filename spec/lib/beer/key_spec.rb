require 'spec_helper'

module Beer

  describe Key do
    it "is constructed from string" do
      key_name, modifiers = *Key.new("UP")
      expect(key_name).to eq("UP")
      expect(modifiers).to eq([])
    end

    it "parses modifier and key" do
      key_name, modifiers = *Key.new("SHIFT+DOWN")
      expect(key_name).to eq("DOWN")
      expect(modifiers).to eq(["SHIFT"])
    end

    it "parses several modifiers" do
      key_name, modifiers = *Key.new("SHIFT+CTRL+RIGHT")
      expect(key_name).to eq("RIGHT")
      expect(modifiers).to eq(["SHIFT", "CTRL"])
    end

    it "does takes care of case and spaces" do
      key_name, modifiers = *Key.new("Cmd + Alt + Left")
      expect(key_name).to eq("LEFT")
      expect(modifiers).to eq(["CMD", "ALT"])
    end

    it "does not allow unknown modifiers" do
      expect { Key.new("Foo+LEFT") }.to raise_error(/unknown.*Foo/i)
    end

    it "does not allow modifiers as main keys" do
      expect { Key.new("Shift+Ctrl") }.to raise_error(/non-modifier/)
    end

    it "has convenient shortcut" do
      key_name, modifiers = *Key("Shift+Up")
      expect(key_name).to eq("UP")
      expect(modifiers).to eq(["SHIFT"])
    end

    it "has meaningful #inspect" do
      expect(Key("Shift+Up").inspect).to match(/#<Beer::Key:.* SHIFT\+UP>/)
    end

    it "is == to identical Key" do
      expect(Key("Shift+Up")).to eq(Key("Shift+Up"))
    end

    it "is not == to different Key" do
      expect(Key("Shift+Up")).not_to eq(Key("Shift+Down"))
    end

    specify "#to_s returns human-readable key" do
      expect(Key("Shift+Up").to_s).to eq("SHIFT+UP")
    end
  end

end

