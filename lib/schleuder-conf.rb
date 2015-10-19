require 'thor'
require 'json'
require 'pathname'
require 'net/https'

rootdir = Pathname.new(__FILE__).dirname.dirname.realpath
$:.unshift File.join(rootdir, 'lib')

require 'schleuder-conf/helper'
require 'schleuder-conf/version'
require 'schleuder-conf/subcommand_fix'
require 'schleuder-conf/subscriptions'
require 'schleuder-conf/lists'
require 'schleuder-conf/keys'
require 'schleuder-conf/base'
