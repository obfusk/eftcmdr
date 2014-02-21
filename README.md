[]: {{{1

    File        : README.md
    Maintainer  : Felix C. Stegerman <flx@obfusk.net>
    Date        : 2014-02-20

    Copyright   : Copyright (C) 2014  Felix C. Stegerman
    Version     : v0.4.0

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

  You can use `eftcmdr-ssh-setup` to generate a
  `~/.ssh/authorized_keys` from `~/.eftcmdr.d/*.{pub,yml}` (see
  `examples/`).  This allows you to use `eftcmdr` to provide a menu
  over `ssh -t` that allows selected users to perform selected
  actions.

  **NB**: be careful what you allow -- access to e.g. a rails console
  makes it trivial to get complete shell access.

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
