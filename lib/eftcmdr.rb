# --                                                            ; {{{1
#
# File        : eftcmdr.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-02-17
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : LGPLv3+
#
# --                                                            ; }}}1

require 'eft'
require 'erb'
require 'yaml'

module EftCmdr

  SSH_LINE = -> cmd, key, comment {
    %Q{command="#{cmd}",no-agent-forwarding,no-port-forwarding,no-X11-forwarding #{key} #{comment}}
  }

  FILES = []

  def self.run(spec, ctx = {})
    %w{ eval menu ask ask_pass ask_yesno show_text }.each do |x|
      return self.send x, spec, ctx if spec[x]
    end
    raise 'invalid spec'
  end

  def self.then_run(spec, ctx, ctx_)
    run spec, ctx.merge(ctx_) if spec
  end

  def self.evaluate(spec, ctx)
    s = Struct.new(:ctx).class_eval { def _binding; binding; end; self }
    s.new(ctx)._binding.eval spec['code']
  end

  def self.eval(spec, ctx)
    v = evaluate spec, ctx
    then_run spec['then'], ctx, spec['eval'].to_sym => v
  end

  # --

  def self.menu(spec, ctx)                                      # {{{1
    Eft.menu(spec['text'], title: spec['title'], ) do |m|
      spec['choices'].each do |c|
        m.on(c['tag'], c['text']) do |x|
          then_run (c['then'] || spec['then']), ctx,
            spec['menu'].to_sym => { tag: c['tag'], text: c['text'] }
        end
      end
    end
  end                                                           # }}}1

  def self.ask(spec, ctx)                                       # {{{1
    Eft.ask(spec['text']) do |q|
      q.on_ok do |x|
        x =~ Regexp.new(spec['validate']) or raise "invalid: #{x}" \
          if spec['validate']
        then_run spec['then'], ctx, spec['ask'].to_sym => x
      end
    end
  end                                                           # }}}1

  def self.ask_pass(spec, ctx)                                  # {{{1
    Eft.ask_pass(spec['text']) do |q|
      q.on_ok do |x|
        then_run spec['then'], ctx, spec['ask_pass'].to_sym => x
      end
    end
  end                                                           # }}}1

  def self.ask_yesno(spec, ctx)                                 # {{{1
    Eft.ask_yesno spec['text'] do |q|
      q.on_yes do
        then_run spec['then'], ctx, spec['ask_yesno'].to_sym => true
      end
      q.on_no do
        then_run spec['then'], ctx, spec['ask_yesno'].to_sym => false
      end
    end
  end                                                           # }}}1

  def self.show_text(spec, ctx)                                 # {{{1
    v = evaluate spec, ctx
    Eft.show_text(text: v) do |t|
      t.on_ok do
        then_run spec['then'], ctx, spec['show_text'].to_sym => v
      end
    end
  end                                                           # }}}1

  # --

  def self.file
    FILES.last
  end

  def self.load_yaml(file)
    FILES << file
    v = YAML.load ERB.new(File.read(file)).result
    FILES.pop
    v
  end

  # turn ~/.eftcmdr.d into ~/.ssh/authorized_keys
  def self.build_authorized_keys(file, dir)                     # {{{1
    dir =~ %r{\A[A-Za-z0-9_./-]+\z} or raise "invalid dir name: #{dir}"
    original  = (File.exists?(file) ? File.read(file) : '') \
                  .lines.reject { |l| l =~ /EFTCMDR/ }
    lines     = Dir.glob["#{dir}/*.pub"].map do |x|
      x =~ %r{\A[A-Za-z0-9_.-]+\z} or raise "invalid file name: #{x}"
      b = File.basename x
      f = File.exists?("#{b}.yml") ? "#{b}.yml" : 'default.yml'
      SSH_LINE["eftcmdr #{dir}/#{f}", File.read(x), "(EFTCMDR #{x})"]
    end
    File.open(file, 'w') do |f|
      (original + lines).each { |l| f.puts l }
    end
  end                                                           # }}}1

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
