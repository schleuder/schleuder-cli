require 'bundler/setup'
Bundler.setup
require 'schleuder-cli'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    # be_bigger_than(2).and_smaller_than(4).description
    #   # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #   # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.order = :random

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end
end

def start_api_daemon
  if ! @api_daemon_pid
    @api_daemon_pid = Process.spawn 'spec/static-schleuder-api-daemon', {'redirection' => { :out => '/dev/null' }}
    sleep 2
  end
end

def stop_api_daemon
  if @api_daemon_pid
    Process.kill(15, @api_daemon_pid)
  end
end

def run_cli(args=[])
  ENV['SCHLEUDER_CLI_CONFIG'] = 'spec/schleuder-cli.yml'
  output = ''
  $stdout = StringIO.new(output)
  SchleuderCli::Base.start(Array(args))
  $stdout = STDOUT
  return output.chomp
end
