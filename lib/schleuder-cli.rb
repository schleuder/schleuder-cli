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

DEFAULT_CONFIG_FILE = File.join(ENV['HOME'], '.schleuder-cli/schleuder-cli.yml')
