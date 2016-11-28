require 'thor'
require 'json'
require 'pathname'
require 'net/https'
require 'uri'
require 'singleton'
require 'yaml'

rootdir = Pathname.new(__FILE__).dirname.dirname.realpath
$:.unshift File.join(rootdir, 'lib')

# TODO: don't always `require` everything, only the relevant classes.
require 'schleuder-cli/conf'
require 'schleuder-cli/helper'
require 'schleuder-cli/version'
require 'schleuder-cli/subcommand_fix'
require 'schleuder-cli/subscriptions'
require 'schleuder-cli/lists'
require 'schleuder-cli/keys'
require 'schleuder-cli/base'

ENV['SCHLEUDER_CLI_ROOT'] = Pathname.new(__FILE__).dirname.dirname.realpath.to_s
ENV["SCHLEUDER_CLI_CONFIG"] ||= File.join(ENV['HOME'], '.schleuder-cli/schleuder-cli.yml')