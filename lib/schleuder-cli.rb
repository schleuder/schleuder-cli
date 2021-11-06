require 'thor'
require 'json'
require 'pathname'
require 'net/https'
require 'uri'
require 'cgi'
require 'singleton'
require 'yaml'
require 'base64'

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
require 'schleuder-cli/openssl_ssl_patch'

ENV["SCHLEUDER_CLI_CONFIG"] ||= File.join(ENV['HOME'], '.schleuder-cli/schleuder-cli.yml')
