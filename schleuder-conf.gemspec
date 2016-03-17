# encoding: utf-8

$: << File.expand_path('../lib', __FILE__)
require 'schleuder-conf/version'

Gem::Specification.new do |s|
  s.name         = "schleuder-conf"
  s.version      = SchleuderConf::VERSION
  s.authors      = %w(paz)
  s.email        = "schleuder2@nadir.org"
  s.homepage     = "http://schleuder.nadir.org/"
  s.summary      = "A command line tool to configure schleuder-lists."
  s.description  = "Schleuder-conf enables creating, configuring, and deleting schleuder-lists, subscriptions, keys, etc. Currently it must be run on the same system that runs the schleuderd."
  s.files        = `git ls-files lib README.md`.split
  s.executables =  `git ls-files bin`.split.map {|file| File.basename(file) }
  s.platform     = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.rubyforge_project = '[none]'
  # TODO: extend/replace expired cert
  #s.signing_key = "#{ENV['HOME']}/.gem/schleuder-gem-private_key.pem"
  #s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'GPL-3.0'
  s.add_runtime_dependency 'thor', '~> 0'
end
