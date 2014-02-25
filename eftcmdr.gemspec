require File.expand_path('../lib/eftcmdr/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'eftcmdr'
  s.homepage    = 'https://github.com/obfusk/eftcmdr'
  s.summary     = 'yaml + ruby + whiptail'

  s.description = <<-END.gsub(/^ {4}/, '')
    EftCmdr is a yaml dsl that wraps whiptail to display dialog boxes.
    It provides a yaml dsl on top of eft.  See examples/ for examples.
  END

  s.version     = EftCmdr::VERSION
  s.date        = EftCmdr::DATE

  s.authors     = [ 'Felix C. Stegerman' ]
  s.email       = %w{ flx@obfusk.net }

  s.licenses    = %w{ LGPLv3+ }

  s.executables = %w{ eftcmdr eftcmdr-ssh-setup eftcmdr-ssh-wrapper
                      eftcmdr-ssh-wrapper.sh }
  s.files       = %w{ .yardopts README.md Rakefile eftcmdr.gemspec } \
                + Dir['examples/**/*.{yml,apps}'] \
                + Dir['lib/**/*.rb']

  s.add_runtime_dependency 'eft'
  s.add_runtime_dependency 'obfusk-util', '>= 0.5.0'

  s.add_development_dependency 'rake'
# s.add_development_dependency 'rspec'

  s.required_ruby_version = '>= 1.9.1'
end
