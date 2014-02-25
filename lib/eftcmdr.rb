# --                                                            ; {{{1
#
# File        : eftcmdr.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-02-25
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : LGPLv3+
#
# --                                                            ; }}}1

require 'erb'
require 'yaml'

require 'eft'
require 'obfusk/util/message'
require 'obfusk/util/sh'

module EftCmdr

  class InvalidFileNameError  < RuntimeError; end
  class InvalidSpecError      < RuntimeError; end
  class ValidationError       < RuntimeError; end

  # --

  # state: context, data, binding
  class State < Struct.new(:ctx, :data, :scope)                 # {{{1
    def initialize(ctx, data, scope = nil)
      super ctx, data, scope || data._binding
    end
    def merge_ctx(ctx_)
      self.class.new ctx.merge(ctx_), data, scope
    end
    def eval(code)
      data.ctx = ctx; scope.eval code
    end
  end                                                           # }}}1

  # data: file, args, context
  class Data < Struct.new(:file, :args, :ctx)
    %w{ ohai onow onoe opoo sh sh? sh! shc shc? shc! osh osh? osh!
        oshc osch? oshc! }.each do |m|
      define_method(m) { |*a,&b| Obfusk::Util.send(m, *a, &b) }
    end
    def _binding; binding; end
  end

  # --

  SSH_LINE = -> cmd, key, comment {
    %Q{command="#{cmd}",no-agent-forwarding,no-port-forwarding,} +
      %Q{no-X11-forwarding #{key} #{comment}}
  }

  ACTIONS = %w{ eval menu check radio ask ask_pass ask_yesno
                show_msg show_text }

  # --

  # run self.$ACTION
  def self.run(spec, state = new_state)
    ACTIONS.each { |x| return self.send x, spec, state if spec[x] }
    raise InvalidSpecError, 'no action found'
  end

  # run w/ merged ctx if there is a next action to run
  def self.then_run(spec, state, ctx = {})
    run spec, state.merge_ctx(ctx) if spec
  end

  # --

  # evaluate and continue
  def self.eval(spec, state, &b)
    v = state.eval spec['code']
    n = v ? spec['then'] : spec['else'] || spec['then']
    b ? b[v,n] : then_run(n, state, spec['eval'].to_sym => v)
  end

  # --

  # new state
  def self.new_state(file = nil, args = [])
    State.new({}, Data.new(file, args, nil))
  end

  # load yaml (parsed w/ ERB)
  # @return [Array] [yaml,state]
  def self.load_yaml(file, *args)
    s = new_state file, args
    y = YAML.load ERB.new(File.read(file)).result s.scope
    [y,s]
  end

  # handle `on_{cancel,esc}`
  def self.on_cancel_esc(e, spec, state)
    e.on_cancel { then_run spec['cancel'], state } \
      if e.respond_to? :on_cancel
    e.on_esc { then_run spec['esc'], state } \
      if e.respond_to? :on_esc
  end

  # helper
  def self._opts(spec, more = {})
    { title: spec['title'], scroll: spec['scroll'] } .merge more
  end

  # --

  # menu
  def self.menu(spec, state)                                    # {{{1
    Eft.menu spec['text'],
        _opts(spec, selected: spec['selected']) do |m|
      spec['choices'].each do |c|
        m.on(c['tag'], c['text']) do |x|
          then_run (c['then'] || spec['then']), state,
            spec['menu'].to_sym => { tag: c['tag'], text: c['text'] }
        end
      end
      on_cancel_esc m, spec, state
    end
  end                                                           # }}}1

  # checkboxes
  def self.check(spec, state)                                   # {{{1
    Eft.check spec['text'], _opts(spec) do |cb|
      spec['choices'].each do |c|
        cb.choice c['tag'], c['text'], c['selected']
      end
      cb.on_ok do |choices|
        then_run spec['then'], state, spec['check'].to_sym => choices
      end
      on_cancel_esc cb, spec, state
    end
  end                                                           # }}}1

  # radiolist
  def self.radio(spec, state)                                   # {{{1
    Eft.radio spec['text'],
        _opts(spec, selected: spec['selected']) do |r|
      spec['choices'].each do |c|
        c.choice c['tag'], c['text']
      end
      r.on_ok do |choice|
        then_run spec['then'], state, spec['radio'].to_sym => choice
      end
      on_cancel_esc r, spec, state
    end
  end                                                           # }}}1

  # --

  # ask
  def self.ask(spec, state)                                     # {{{1
    Eft.ask spec['text'], _opts(spec, default: spec['default']) do |q|
      q.on_ok do |x|
        x =~ Regexp.new(spec['validate']) \
          or raise ValidationError, "#{x} !~ #{spec['validate']}" \
            if spec['validate']
        then_run spec['then'], state, spec['ask'].to_sym => x
      end
      on_cancel_esc q, spec, state
    end
  end                                                           # }}}1

  # ask password
  def self.ask_pass(spec, state)                                # {{{1
    Eft.ask_pass spec['text'], _opts(spec) do |q|
      q.on_ok do |x|
        then_run spec['then'], state, spec['ask_pass'].to_sym => x
      end
      on_cancel_esc q, spec, state
    end
  end                                                           # }}}1

  # ask yes/no
  def self.ask_yesno(spec, state)                               # {{{1
    Eft.ask_yesno spec['text'], _opts(spec) do |q|
      q.on_yes do
        then_run spec['then'], state, spec['ask_yesno'].to_sym => true
      end
      q.on_no do
        then_run (spec['else'] || spec['then']), state,
          spec['ask_yesno'].to_sym => false
      end
      on_cancel_esc q, spec, state
    end
  end                                                           # }}}1

  # --

  # show message
  def self.show_msg(spec, state)                                # {{{1
    o = _opts(spec)
    if spec['code']
      eval spec, state do |v,n|
        Eft.show_msg v, o do |t|
          t.on_ok { then_run n, state, spec['show_msg'].to_sym => v }
          on_cancel_esc t, spec, state
        end
      end
    elsif spec['text']
      Eft.show_msg spec['text'], o do |t|
        t.on_ok { then_run spec['then'], state }
        on_cancel_esc t, spec, state
      end
    else
      raise InvalidSpecError, 'show_msg needs code or text'
    end
  end                                                           # }}}1

  # show text/file
  def self.show_text(spec, state)                               # {{{1
    if spec['code']
      eval spec, state do |v,n|
        Eft.show_text _opts(spec, text: v) do |t|
          t.on_ok { then_run n, state, spec['show_text'].to_sym => v }
          on_cancel_esc t, spec, state
        end
      end
    elsif spec['text']
      Eft.show_text _opts(spec, text: spec['text']) do |t|
        t.on_ok { then_run spec['then'], state }
        on_cancel_esc t, spec, state
      end
    elsif spec['file']
      Eft.show_text _opts(spec, file: spec['file']) do |t|
        t.on_ok { then_run spec['then'], state }
        on_cancel_esc t, spec, state
      end
    else
      raise InvalidSpecError, 'show_text needs code, text, or file'
    end
  end                                                           # }}}1

  # --

  # turn dir (e.g. `~/.eftcmdr.d`) into file (e.g.
  # `~/.ssh/authorized_keys`): each `dir/$USER.pub` is added to `file`
  # w/ forced command `cmd dir/$USER.yml $USER`; added entries are
  # marked w/ a comment that includes the text `EFTCMDR` so that they
  # can be ignored on subsequent runs.
  def self.build_authorized_keys(file, dir, cmd)                # {{{1
    dir =~ %r{\A[A-Za-z0-9_./-]+\z} \
      or raise InvalidFileNameError, "invalid dir name: #{dir}"
    cmd =~ %r{\A[A-Za-z0-9_./-]+\z} \
      or raise InvalidFileNameError, "invalid command name: #{cmd}"
    original = (File.exists?(file) ? File.read(file) : '') \
                 .lines.reject { |l| l =~ /EFTCMDR/ }
    lines = Dir["#{dir}/*.pub"].sort.map do |x|
      b = File.basename x, '.pub'
      b =~ %r{\A[A-Za-z0-9_.-]+\z} \
        or raise InvalidFileNameError, "invalid file name: #{x}"
      k = File.read(x).chomp; f = x.sub /\.pub\z/, '.yml'
      SSH_LINE["#{cmd} #{f} #{b}", k, "(EFTCMDR #{x})"]
    end
    File.open(file, 'w') do |f|
      (original + lines).each { |l| f.puts l }
    end
  end                                                           # }}}1

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
