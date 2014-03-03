[]: {{{1

    File        : README.md
    Maintainer  : Felix C. Stegerman <flx@obfusk.net>
    Date        : 2014-03-03

    Copyright   : Copyright (C) 2014  Felix C. Stegerman
    Version     : v0.4.1

[]: }}}1

[![Gem Version](https://badge.fury.io/rb/eftcmdr.png)](http://badge.fury.io/rb/eftcmdr)

## Description
[]: {{{1

  eftcmdr - yaml + ruby + whiptail

  EftCmdr is a yaml dsl that wraps `whiptail` [1] to display dialog
  boxes.  It provides a yaml dsl on top of `eft` [2].  See `examples/`
  for examples.

```yaml
ask:    ask_name
text:   What is your name?
then:
  eval: eval_hello
  code: |
    puts "Hello, #{ctx[:ask_name]}!"
```

```bash
$ eftcmdr examples/hello.yml
```

### SSH

[]: {{{2

  You can use `eftcmdr-ssh-setup` to generate a
  `~/.ssh/authorized_keys` from `~/.eftcmdr.d/*.{pub,yml}` (see
  `examples/`).  This allows you to use `eftcmdr` to provide a menu
  over `ssh -t` that allows selected users to perform selected
  actions.

  **NB**: be careful what you allow -- access to e.g. `rails console`
  or `less` makes it trivial to get complete shell access.

  You may need to load e.g. `~/.profile` (e.g. when `eftcmdr` is not
  in the default `$PATH`).  To make this easier, you can pass a third
  argument to `eftcmdr-ssh-setup` (or set `$EFTCMDR_SSH_COMMAND`) to
  choose the command to be put in the `authorized_keys` file.  You can
  use e.g. `$( which eftcmdr-ssh-wrapper )` to wrap `eftcmdr` in a
  shell script that sources `~/.eftcmdr_env` (which can e.g. be a
  symlink to `~/.profile`).

[]: }}}2

### Links

&rarr; [blog
post](http://obfusk.github.io/_/dev/2014-02-24/eft___eftcmdr__dialog_boxes_w__ruby__yaml_and_whiptail.html)
(with pictures!)

&rarr; [more complicated example yml
file](https://gist.github.com/obfusk/9188866)

[]: }}}1

## Specs & Docs

```bash
$ rake spec   # TODO
$ rake docs
```

## TODO

  * gauge?
  * options?
  * specs! (how to automate tests of whiptail? - I don't know!)

## License

  LGPLv3+ [3].

## References

  [1] Newt (and whiptail)
  --- http://en.wikipedia.org/wiki/Newt_(programming_library)

  [2] eft
  --- https://github.com/obfusk/eft

  [3] GNU Lesser General Public License, version 3
  --- http://www.gnu.org/licenses/lgpl-3.0.html

[]: ! ( vim: set tw=70 sw=2 sts=2 et fdm=marker : )
