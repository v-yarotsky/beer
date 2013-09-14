Beer
====

Beer is a client script for [Zephyros](https://github.com/sdegutis/zephyros) - OS X window manager server.
Beer implements a window-management mode triggered by a single hotkey.
That is, you press a hotkey to activate window management mode, press a (rapid)
sequence of keys to execute desired action without feeling oneself an Emacs adept :D

Current features:

`Shift + F13` - enable window management mode

* `Up`           - top half of window's screen
* `Down`         - bottom half of window's screen
* `Left`         - left half of window's screen
* `Right`        - right half of window's screen
* `Up, Left`     - top left quarter of window's screen
* `Up, Right`    - top right quarter of window's screen
* `Down, Left`   - bottom left quarter of window's screen
* `Down, Right`  - bottom right quarter of window's screen
* `Enter`        - maximize window
* `Left, Left`   - move window to previous screen
* `Right, Right` - move window to next screen
* `W`            - focus window to the top
* `S`            - focus window to the bottom
* `A`            - focus window to the left
* `D`            - focus window to the right
* `Esc`          - dismiss window-management mode (it's dismissed automatically on action though)

Disclaimer
----------

This is experimental software and most probably it will be rewritten eventually.

