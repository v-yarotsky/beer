require 'beer/mode'

module Beer

  class ManualWindowManagementMode < Mode
    def initialize(api, options)
      super(api, options)

      set_keys_tree_from_commands(
        Command.new("left_half",             Key("Left"))                { |win| resize_window(win, "half_left_rect") },
        Command.new("top_half",              Key("Up"))                  { |win| resize_window(win, "half_top_rect") },
        Command.new("right_half",            Key("Right"))               { |win| resize_window(win, "half_right_rect") },
        Command.new("bottom_half",           Key("Down"))                { |win| resize_window(win, "half_bottom_rect") },
        Command.new("top_left_quarter",      Key("Up"), Key("Left") )    { |win| resize_window(win, "top_left_quarter_rect") },
        Command.new("top_right_quarter",     Key("Up"), Key("Right"))    { |win| resize_window(win, "top_right_quarter_rect") },
        Command.new("bottom_right_quarter",  Key("Down"), Key("Right"))  { |win| resize_window(win, "bottom_right_quarter_rect") },
        Command.new("bottom_left_quarter",   Key("Down"), Key("Left"))   { |win| resize_window(win, "bottom_left_quarter_rect") },
        Command.new("maximize",              Key("Return"))              { |win| resize_window(win) },
        Command.new("move_to_left_screen",   Key("Left"), Key("Left"))   { |win| move_window_to_screen(win, win.screen.previous_screen) },
        Command.new("move_to_right_screen",  Key("Right"), Key("Right")) { |win| move_window_to_screen(win, win.screen.next_screen) },
        Command.new("focus_window_left",     Key("a"))                   { |win| win.focus_window_left },
        Command.new("focus_window_up",       Key("w"))                   { |win| win.focus_window_up },
        Command.new("focus_window_right",    Key("d"))                   { |win| win.focus_window_right },
        Command.new("focus_window_down",     Key("s"))                   { |win| win.focus_window_down },
        Command.new("dismiss",               Key("Escape"))              {}
      )
    end

    def on_activate
      @api.show_box("Magic!")
    end

    def on_deactivate
      @api.hide_box
    end

    def move_window_to_screen(window, target_screen)
      frame = target_screen.frame_without_dock_or_menu
      frame.w = [frame.w, window.frame.w].min
      frame.h = [frame.h, window.frame.h].min
      window.frame = frame
    end
    private :move_window_to_screen

    def resize_window(window, transformation = nil)
      screen_frame = TransformableRect.new(window.screen.frame_without_dock_or_menu)
      window.frame = transformation ? screen_frame.public_send(transformation) : screen_frame
    end
    private :resize_window
  end

end

