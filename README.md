Beer
====

Beer is a client script for [Zephyros](https://github.com/sdegutis/zephyros) - OS X window manager server.
Beer implements a window-management mode triggered by a single hotkey.
That is, you press a hotkey to activate window management mode, press a (rapid)
sequence of keys to execute desired action without feeling oneself an Emacs adept :D

Current features:

`Ctrl+Alt+W` - enable window management mode

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

Configuration
-------------

Some configuration can be overridden through `~/.beer.yml`.
Available options are:
  * `mode_key`             - window management mode trigger key shortcut.
  * `key_sequence_timeout` - key sequence conflict resolution timeout
  * `log`                  - log file name (Beer will log debug output if DEBUG environment variable is set)

A little demo
-------------

[![Beer WM Demo](http://img.youtube.com/vi/p_U7Y6txWn8/0.jpg)](http://www.youtube.com/watch?v=p_U7Y6txWn8)

Hint
----

I've installed KeyRemap4MacBook and remapped right Option key to F13, and set my `mode_key` to `Shift+F13`

Disclaimer
----------

This is experimental software and most probably it will be rewritten eventually.

License
-------

> Released under MIT license.
>
> Copyright (c) 2013 Vladimir Yarotsky
>
> Permission is hereby granted, free of charge, to any person obtaining a copy
> of this software and associated documentation files (the "Software"), to deal
> in the Software without restriction, including without limitation the rights
> to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
> copies of the Software, and to permit persons to whom the Software is
> furnished to do so, subject to the following conditions:
>
> The above copyright notice and this permission notice shall be included in
> all copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
> IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
> FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
> AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
> LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
> OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
> THE SOFTWARE.

