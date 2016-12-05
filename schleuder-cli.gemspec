# encoding: utf-8

$: << File.expand_path('../lib', __FILE__)
require 'schleuder-cli/version'

Gem::Specification.new do |s|
  s.name         = "schleuder-cli"
  s.version      = SchleuderCli::VERSION
  s.authors      = %w(paz)
  s.email        = "schleuder@nadir.org"
  s.homepage     = "https://schleuder.nadir.org/"
  s.summary      = "A command line tool to configure schleuder-lists."
  s.description  = "Schleuder-cli enables creating, configuring, and deleting schleuder-lists, subscriptions, keys, etc."
  s.files        = `git ls-files man lib README.md`.split
  s.executables =  `git ls-files bin`.split.map {|file| File.basename(file) }
  s.platform     = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.rubyforge_project = '[none]'
  # TODO: extend/replace expired cert
  #s.signing_key = "#{ENV['HOME']}/.gem/schleuder-gem-private_key.pem"
  #s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'GPL-3.0'
  s.add_runtime_dependency 'thor', '~> 0'
  s.add_development_dependency 'rspec', '~> 3.5.0'
end
