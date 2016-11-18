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
require 'schleuder-conf/conf'
require 'schleuder-conf/helper'
require 'schleuder-conf/version'
require 'schleuder-conf/subcommand_fix'
require 'schleuder-conf/subscriptions'
require 'schleuder-conf/lists'
require 'schleuder-conf/keys'
require 'schleuder-conf/base'

ENV['SCHLEUDER_CONF_ROOT'] = Pathname.new(__FILE__).dirname.dirname.realpath.to_s
ENV["SCHLEUDER_CONF_CONFIG"] ||= File.join(ENV['HOME'], '.schleuder-conf/config.yml')
