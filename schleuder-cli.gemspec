# encoding: utf-8

$: << File.expand_path('../lib', __FILE__)
require 'schleuder-cli/version'

Gem::Specification.new do |s|
  s.name         = "schleuder-cli"
  s.version      = SchleuderCli::VERSION
  s.authors      = 'schleuder dev team'
  s.email        = "team@schleuder.org"
  s.homepage     = "https://schleuder.org/"
  s.summary      = "A command line tool to configure schleuder-lists."
  s.description  = "Schleuder-cli enables creating, configuring, and deleting schleuder-lists, subscriptions, keys, etc."
  s.files        = `git ls-files man lib README.md`.split
  s.executables  = `git ls-files bin`.split.map {|file| File.basename(file) }
  s.test_files   = `git ls-files spec/`.split
  s.platform     = Gem::Platform::RUBY
  s.require_path = 'lib'
  # TODO: extend/replace expired cert
  #s.signing_key = "#{ENV['HOME']}/.gem/schleuder-gem-private_key.pem"
  #s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'GPL-3.0-only'
  s.add_runtime_dependency 'thor', '~> 1'
  if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.3.0")
    s.add_runtime_dependency 'base64', '~> 0.2.0'
  end
  s.add_development_dependency 'rspec', '~> 3.13'
end
