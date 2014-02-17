require File.expand_path('../lib/eftcmdr/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'eftcmdr'
  s.homepage    = 'https://github.com/obfusk/eftcmdr'
  s.summary     = '...'

  s.description = <<-END.gsub(/^ {4}/, '')
    ...
  END

  s.version     = EftCmdr::VERSION
  s.date        = EftCmdr::DATE

  s.authors     = [ 'Felix C. Stegerman' ]
  s.email       = %w{ flx@obfusk.net }

  s.licenses    = %w{ LGPLv3+ }

  s.executables = %w{ eftcmdr eftcmdr-ssh-setup }
  s.files       = %w{ .yardopts README.md eftcmdr.gemspec } \
                + Dir['lib/**/*.rb']

  s.add_runtime_dependency 'eft'

  s.add_development_dependency 'rake'
# s.add_development_dependency 'rspec'

  s.required_ruby_version = '>= 1.9.1'
end
